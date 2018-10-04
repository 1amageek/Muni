//
//  MessagesViewController.swift
//  Muni
//
//  Created by 1amageek on 2018/07/31.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import UIKit
import Pring
import FirebaseFirestore
import Toolbar

extension Muni {
    /**
     A ViewController that displays a message.
     */
    open class MessagesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching, UITextViewDelegate {
        
        /// Returns the Room holding the message.
        public let room: RoomType
        
        /// Returns the toolbar to display in inputAccessoryView.
        public var toolBar: Toolbar = Toolbar()
        
        /// limit The maximum number of transcripts to return.
        public let limit: Int
        
        /// Returns the DataSource of Transcript.
        public var dataSource: DataSource<TranscriptType>
        
        /// Returns a CollectionView that displays a message.
        public private(set) var collectionView: MessagesView!
        
        /// Returns a Section that reflects the update of the data source.
        open var targetSection: Int {
            return 0
        }
        
        open var calendar: Calendar = Calendar.current
        
        /// Returns the textView of inputAccessoryView.
        open var textView: UITextView = {
            let textView: UITextView = UITextView(frame: .zero)
            textView.font = UIFont.systemFont(ofSize: 15)
            textView.layer.cornerRadius = 12
            textView.layer.borderColor = UIColor.lightGray.cgColor
            textView.layer.borderWidth = 1 / UIScreen.main.scale
            textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            return textView
        }()
        
        open lazy var titleView: MessagesTitleView? = {
            guard let senderID: String = self.senderID else {
                fatalError("[Muni] error: You need to override senderID.")
            }
            let titleView: MessagesTitleView = UINib(nibName: "MessagesTitleView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MessagesTitleView
            if let name: String = self.room.name {
                titleView.nameLabel.text = name
            } else if let config: [String: Any] = room.config[senderID] as? [String: Any] {
                if let nameKey: String = RoomType.configNameKey {
                    titleView.nameLabel.text = config[nameKey] as? String
                }
            }
            return titleView
        }()
        
        public var isLoading: Bool = false {
            didSet {
                if isLoading != oldValue, isLoading {
                    self.dataSource.next()
                }
            }
        }
        
        /// Always override this property.
        open var senderID: String? {
            return nil
        }
        
        /// A Boolean value that determines whether the `MessagesCollectionView` scrolls to the
        /// bottom whenever the `InputTextView` begins editing.
        ///
        /// The default value of this property is `false`.
        open var scrollsToBottomOnKeybordBeginsEditing: Bool = false
        
        open override var canBecomeFirstResponder: Bool {
            return true
        }
        
        open override var inputAccessoryView: UIView? {
            return self.toolBar
        }
        
        open override var shouldAutorotate: Bool {
            return false
        }
        
        /// Returns the date format of the message.
        open var dateFormatter: DateFormatter = {
            let formatter: DateFormatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            formatter.doesRelativeDateFormatting = true
            return formatter
        }()
        
        /// Returns the date format of the message.
        open var timeFormatter: DateFormatter = {
            let formatter: DateFormatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            formatter.doesRelativeDateFormatting = true
            return formatter
        }()
        
        // MARK: -
        
        internal var constraint: NSLayoutConstraint?
        
        internal var isFirstFetching: Bool = true
        
        internal var collectionViewBottomInset: CGFloat = 0 {
            didSet {
                self.collectionView.contentInset.bottom = collectionViewBottomInset
                self.collectionView.scrollIndicatorInsets.bottom = collectionViewBottomInset
            }
        }
        
        internal var keyboardOffsetFrame: CGRect {
            guard let inputFrame = inputAccessoryView?.frame else { return .zero }
            return CGRect(origin: inputFrame.origin, size: CGSize(width: inputFrame.width, height: inputFrame.height - self.collectionView.safeAreaBottomInset))
        }
        
        internal func addKeyboardObservers() {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }
        
        internal func removeKeyboardObservers() {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }
        
        // MARK: -
        
        public convenience init(roomID: String, fetching limit: Int = 20) {
            let room: RoomType = RoomType(id: roomID, value: [:])
            self.init(room: room, fetching: limit)
        }
        
        public init(room: RoomType, fetching limit: Int = 20) {
            self.limit = limit
            self.room = room
            let options: Options = Options()
            options.listeningChangeTypes = [.added, .modified]
            options.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: true)]
            self.dataSource = room.transcripts
                .order(by: "updatedAt", descending: true)
                .limit(to: limit)
                .dataSource(options: options)
            super.init(nibName: nil, bundle: nil)
        }
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        open override func loadView() {
            super.loadView()
            self.textView.delegate = self
            let collectionViewLayout: MessagesViewFlowLayout = MessagesViewFlowLayout()
            self.collectionView = MessagesView(frame: self.view.bounds, collectionViewLayout: collectionViewLayout)
            self.collectionView.backgroundColor = .white
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            self.collectionView.prefetchDataSource = self
            self.collectionView.isPrefetchingEnabled = true
            self.collectionView.bounces = true
            self.collectionView.alwaysBounceVertical = true
            self.collectionView.keyboardDismissMode = .interactive
            self.collectionView.register(UINib(nibName: "MessageViewCell", bundle: nil), forCellWithReuseIdentifier: "MessageViewCell")
            self.collectionView.register(UINib(nibName: "MessageViewLeftCell", bundle: nil), forCellWithReuseIdentifier: "MessageViewLeftCell")
            self.collectionView.register(UINib(nibName: "MessageViewRightCell", bundle: nil), forCellWithReuseIdentifier: "MessageViewRightCell")
            self.view.addSubview(self.collectionView)
            self.toolBar.setItems([ToolbarItem(customView: self.textView)], animated: false)
        }
        
        open override func viewDidLoad() {
            super.viewDidLoad()
            self.navigationItem.titleView = self.titleView
            self.dataSource
                .on(parse: { (_, transcript, done) in
                    transcript.from.get({ (user, error) in
                        done(transcript)
                    })
                })
                .on({ [weak self] (snapshot, changes) in
                    guard let collectionView: MessagesView = self?.collectionView else { return }
                    guard let dataSource: DataSource<TranscriptType> = self?.dataSource else { return }
                    guard let section: Int = self?.targetSection else { return }
                    switch changes {
                    case .initial:
                        collectionView.reloadData()
                        collectionView.setNeedsLayout()
                        collectionView.layoutIfNeeded()
                        collectionView.scrollToBottom()
                        self?.didInitialize(of: dataSource)
                    case .update(let deletions, let insertions, let modifications):
                        collectionView.performBatchUpdates({
                            collectionView.insertItems(at: insertions.map { IndexPath(row: $0, section: section) })
                            collectionView.deleteItems(at: deletions.map { IndexPath(row: $0, section: section) })
                            collectionView.reloadItems(at: modifications.map { IndexPath(row: $0, section: section) })
                            if snapshot?.metadata.hasPendingWrites ?? false {
                                collectionView.scrollToBottom(animated: true)
                            }
                        }, completion: nil)
                    case .error(let error):
                        print(error)
                    }
                }).onCompleted { [weak self] (_, _) in
                    self?.isLoading = false
            }
        }

        open override func viewWillLayoutSubviews() {
            self.collectionView.frame = self.view.bounds
        }

        /// Start listening
        open func listen() {
            self.dataSource.listen()
        }
        
        open override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            self.markAsRead()
            addKeyboardObservers()
        }
        
        open override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            removeKeyboardObservers()
        }
        
        open override func viewDidLayoutSubviews() {
            self.collectionViewBottomInset = keyboardOffsetFrame.height
        }
        
        open func markAsRead() {
            guard let senderID: String = self.senderID else {
                fatalError("[Muni] error: You need to override senderID.")
            }
            
            var viewers: [String] = self.room.viewers
            if !viewers.contains(senderID) {
                viewers.append(senderID)
                self.room.updateValue["viewers"] = viewers
                self.room.update()
            }
        }
        
        /// It is called after the first fetch of the data source is finished.
        open func didInitialize(of dataSource: DataSource<TranscriptType>) {
            // override
        }
        
        /// Call this method to send the message.
        @objc
        public func send() {
            guard let senderID: String = self.senderID else {
                fatalError("[Muni] error: You need to override senderID.")
            }
            var room: RoomType = self.room
            let transcript: TranscriptType = TranscriptType()
            let sender: UserType = UserType(id: senderID, value: [:])
            transcript.from.set(sender)
            transcript.to.set(room)
            if !self.transcript(willSend: transcript) {
                return
            }
            room.viewers = [senderID]
            room.recentTranscript = transcript.value
            room.transcripts.insert(transcript)
            room.update { [weak self] (error) in
                self?.transcript(didSend: transcript, reference: transcript.reference, error: error)
            }
        }
        
        /// Set contents in Transcript.
        /// It must be overridden.
        /// - returns: If false is set, messages will not be sent.
        open func transcript(willSend transcript: TranscriptType) -> Bool {
            return false
        }
        
        /// Called after the message has been sent.
        open func transcript(didSend transcript: TranscriptType, reference: DocumentReference?, error: Error?) {
            
        }
        
        // MARK: -
        
        open func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
        open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.dataSource.count
        }
        
        open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let senderID: String = self.senderID else {
                fatalError("[Muni] error: You need to override senderID.")
            }
            let transcript: TranscriptType = self.dataSource[indexPath.item]
            
            var day: String? = nil
            if indexPath.item == 0 {
                day = self.dateFormatter.string(from: transcript.updatedAt)
            } else if indexPath.item > 0 {
                let previousIndex: Int = indexPath.item - 1
                let previousTranscript: TranscriptType = self.dataSource[previousIndex]
                let previousDateComponents: DateComponents = self.calendar.dateComponents(in: TimeZone.current, from: previousTranscript.updatedAt)
                let dateComponents: DateComponents = self.calendar.dateComponents(in: TimeZone.current, from: transcript.updatedAt)
                if dateComponents.day != previousDateComponents.day {
                    day = self.dateFormatter.string(from: transcript.updatedAt)
                }
            }
            
            if transcript.from.id! == senderID {
                let cell: MessageViewRightCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageViewRightCell", for: indexPath) as! MessageViewRightCell
                cell.titleLabel.isHidden = day == nil
                cell.titleLabel.text = day
                cell.textLabel.text = transcript.text
                cell.dateLabel.text = self.timeFormatter.string(from: transcript.updatedAt)
                return cell
            } else {
                let cell: MessageViewLeftCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageViewLeftCell", for: indexPath) as! MessageViewLeftCell
                cell.titleLabel.isHidden = day == nil
                cell.titleLabel.text = day
                cell.textLabel.text = transcript.text
                cell.dateLabel.text = self.timeFormatter.string(from: transcript.updatedAt)
                return cell
            }
        }
        
        open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        }
        
        open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            guard let senderID: String = self.senderID else {
                fatalError("[Muni] error: You need to override senderID.")
            }
            let transcript: TranscriptType = self.dataSource[indexPath.item]
            
            var day: String? = nil
            if indexPath.item == 0 {
                day = self.dateFormatter.string(from: transcript.updatedAt)
            } else if indexPath.item > 0 {
                let previousIndex: Int = indexPath.item - 1
                let previousTranscript: TranscriptType = self.dataSource[previousIndex]
                let previousDateComponents: DateComponents = self.calendar.dateComponents(in: TimeZone.current, from: previousTranscript.updatedAt)
                let dateComponents: DateComponents = self.calendar.dateComponents(in: TimeZone.current, from: transcript.updatedAt)
                if dateComponents.day != previousDateComponents.day {
                    day = self.dateFormatter.string(from: transcript.updatedAt)
                }
            }
            
            if transcript.from.id! == senderID {
                let cell: MessageViewRightCell = UINib(nibName: "MessageViewRightCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MessageViewRightCell
                cell.textLabel.text = transcript.text
                cell.titleLabel.isHidden = day == nil
                cell.titleLabel.text = day
                var size: CGSize = cell.sizeThatFits(.zero)
                size.width = UIScreen.main.bounds.width
                return size
            } else {
                let cell: MessageViewLeftCell = UINib(nibName: "MessageViewLeftCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MessageViewLeftCell
                cell.textLabel.text = transcript.text
                cell.titleLabel.isHidden = day == nil
                cell.titleLabel.text = day
                var size: CGSize = cell.sizeThatFits(.zero)
                size.width = UIScreen.main.bounds.width
                return size
            }
        }
        
        // MARK: -
        
        public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
            
        }
        
        // MARK: -
        
        @objc internal func keyboardWillChangeFrame(_ notification: Notification) {
            guard let keyboardEndFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            let newBottomInset: CGFloat = self.view.frame.height - keyboardEndFrame.minY - self.collectionView.safeAreaBottomInset
            collectionViewBottomInset = newBottomInset
        }
        
        // MARK: -
        
        public func textViewDidBeginEditing(_ textView: UITextView) {
            if scrollsToBottomOnKeybordBeginsEditing {
                collectionView.scrollToBottom(animated: true)
            }
        }
        
        open func textViewDidChange(_ textView: UITextView) {
            let size: CGSize = textView.sizeThatFits(textView.bounds.size)
            if let constraint: NSLayoutConstraint = self.constraint {
                textView.removeConstraint(constraint)
            }
            self.constraint = textView.heightAnchor.constraint(equalToConstant: size.height)
            self.constraint?.priority = .defaultHigh
            self.constraint?.isActive = true
        }
        
        // MARK: -
        
        private var threshold: CGFloat {
            if #available(iOS 11.0, *) {
                return -self.view.safeAreaInsets.top
            } else {
                return -self.view.layoutMargins.top
            }
        }
        
        private var canLoadNextToDataSource: Bool = true
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if isFirstFetching {
                self.isFirstFetching = false
                return
            }
            if canLoadNextToDataSource && scrollView.contentOffset.y < threshold && !scrollView.isDecelerating {
                if !self.dataSource.isLast && self.limit <= self.dataSource.count {
                    self.isLoading = true
                    self.canLoadNextToDataSource = false
                }
            }
            if !canLoadNextToDataSource && !scrollView.isTracking && scrollView.contentOffset.y <= threshold {
                self.canLoadNextToDataSource = true
            }
        }
    }
}
