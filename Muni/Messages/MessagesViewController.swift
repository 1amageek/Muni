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
    open class MessagesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

        public let room: RoomType

        public var toolBar: Toolbar = Toolbar()

        public let limit: Int

        public var dataSource: DataSource<TranscriptType>

        public private(set) var collectionView: MessagesView!

        open var textView: UITextView = {
            let textView: UITextView = UITextView(frame: .zero)
            textView.layer.cornerRadius = 8
            textView.layer.borderColor = UIColor.lightGray.cgColor
            textView.layer.borderWidth = 1 / UIScreen.main.scale
            return textView
        }()

        /// override method
        open var senderID: String? {
            return nil
        }

        open var scrollsToBottomOnKeybordBeginsEditing: Bool = true

        open override var canBecomeFirstResponder: Bool {
            return true
        }

        open override var inputAccessoryView: UIView? {
            return toolBar
        }

        open override var shouldAutorotate: Bool {
            return false
        }

        internal var collectionViewBottomInset: CGFloat = 0 {
            didSet {
                self.collectionView.contentInset.bottom = collectionViewBottomInset
                self.collectionView.scrollIndicatorInsets.bottom = collectionViewBottomInset
            }
        }

        internal var keyboardOffsetFrame: CGRect {
            guard let inputFrame = inputAccessoryView?.frame else { return .zero }
            return CGRect(origin: inputFrame.origin, size: CGSize(width: inputFrame.width, height: inputFrame.height - self.view.safeAreaInsets.bottom))
        }

        internal func addKeyboardObservers() {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(textViewDidBeginEditing(_:)), name: .UITextViewTextDidBeginEditing, object: nil)
        }

        internal func removeKeyboardObservers() {
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
            NotificationCenter.default.removeObserver(self, name: .UITextViewTextDidBeginEditing, object: nil)
        }

        // MARK: -

        init(roomID: String, limit: Int = 20) {
            self.limit = limit
            self.room = RoomType(id: roomID, value: [:])
            let options: Options = Options()
            options.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: true)]
            self.dataSource = TranscriptType.where("to", isEqualTo: roomID)
                .order(by: "updatedAt", descending: false)
                .limit(to: limit)
                .dataSource(options: options)
            super.init(nibName: nil, bundle: nil)
        }

        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        open override func loadView() {
            super.loadView()
            let collectionViewLayout: MessagesViewFlowLayout = MessagesViewFlowLayout()
            self.collectionView = MessagesView(frame: self.view.bounds, collectionViewLayout: collectionViewLayout)
            self.collectionView.backgroundColor = .white
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
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
            self.dataSource
                .on(parse: { (_, transcript, done) in
                    transcript.from.get({ (user, error) in
                        done(transcript)
                    })
                })
                .on({ [weak self] (snapshot, changes) in
                    guard let collectionView: MessagesView = self?.collectionView else { return }
                    switch changes {
                    case .initial:
                        collectionView.reloadData()
                        collectionView.setNeedsLayout()
                        collectionView.layoutIfNeeded()
                        collectionView.scrollToBottom()
                    case .update(let deletions, let insertions, let modifications):
                        collectionView.performBatchUpdates({
                            collectionView.insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })
                            collectionView.deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
                            collectionView.reloadItems(at: modifications.map { IndexPath(row: $0, section: 0) })
                        }, completion: nil)
                    case .error(let error):
                        print(error)
                    }
                }).listen()
        }

        open override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            addKeyboardObservers()
        }

        open override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            removeKeyboardObservers()
        }

        open override func viewDidLayoutSubviews() {
            self.collectionViewBottomInset = keyboardOffsetFrame.height
        }

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
            if !self.willSend(transcript: transcript) {
                return
            }
            room.recentTranscript = transcript.value as! [String : Any]
            let batch: WriteBatch = Firestore.firestore().batch()
            transcript.save(batch) { [weak self] (ref, error) in
                self?.didSend(transcript: transcript, reference: ref, error: error)
            }
        }

        /// override method
        open func willSend(transcript: TranscriptType) -> Bool {
            return false
        }

        /// override method
        open func didSend(transcript: TranscriptType, reference: DocumentReference?, error: Error?) {
            
        }

        // MARK: -

        open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.dataSource.count
        }

        open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let senderID: String = self.senderID else {
                fatalError("[Muni] error: You need to override senderID.")
            }
            let transcript: TranscriptType = self.dataSource[indexPath.item]
            if transcript.from.id! == senderID {
                let cell: MessageViewRightCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageViewRightCell", for: indexPath) as! MessageViewRightCell
                cell.textLabel.text = transcript.text
                return cell
            } else {
                let cell: MessageViewLeftCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageViewLeftCell", for: indexPath) as! MessageViewLeftCell
                cell.textLabel.text = transcript.text
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
            if transcript.from.id! == senderID {
                let cell: MessageViewRightCell = UINib(nibName: "MessageViewRightCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MessageViewRightCell
                cell.textLabel.text = transcript.text
                var size: CGSize = cell.sizeThatFits(.zero)
                size.width = UIScreen.main.bounds.width
                return size
            } else {
                let cell: MessageViewLeftCell = UINib(nibName: "MessageViewLeftCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MessageViewLeftCell
                cell.textLabel.text = transcript.text
                var size: CGSize = cell.sizeThatFits(.zero)
                size.width = UIScreen.main.bounds.width
                return size
            }
        }

        // MARK: -

        @objc internal func keyboardWillChangeFrame(_ notification: Notification) {
            guard let keyboardEndFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
            let newBottomInset: CGFloat = self.view.frame.height - keyboardEndFrame.minY - self.view.safeAreaInsets.bottom
            collectionViewBottomInset = newBottomInset
        }

        @objc internal func textViewDidBeginEditing(_ notification: Notification) {
            if scrollsToBottomOnKeybordBeginsEditing {
                collectionView.scrollToBottom(animated: true)
            }
        }
    }
}
