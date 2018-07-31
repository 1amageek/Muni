//
//  MessagesViewController.swift
//  Sample
//
//  Created by 1amageek on 2018/07/27.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import UIKit
import Pring
import FirebaseAuth
import FirebaseFirestore
import OnTheKeyboard
import Toolbar

class MessagesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var room: Room!

    var toolBar: Toolbar = Toolbar()

    var toolbarBottomConstraint: NSLayoutConstraint?

    var keyboardObservers: [Any] = []

    var dataSource: DataSource<Transcript>!

    var collectionView: MessagesView!

    let textView: UITextView = UITextView(frame: .zero)

    var sendBarItem: ToolbarItem!

    let sender: FirebaseAuth.User = Auth.auth().currentUser!

    open var scrollsToBottomOnKeybordBeginsEditing: Bool = true

    internal var collectionViewBottomInset: CGFloat = 0 {
        didSet {
            self.collectionView.contentInset.bottom = collectionViewBottomInset
            self.collectionView.scrollIndicatorInsets.bottom = collectionViewBottomInset
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var inputAccessoryView: UIView? {
        return toolBar
    }

    override var shouldAutorotate: Bool {
        return false
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

    init(roomID: String) {
        self.room = Room(id: roomID, value: [:])
        super.init(nibName: nil, bundle: nil)
        self.sendBarItem = ToolbarItem(title: "Send", target: self, action: #selector(_send))
        self.dataSource = Transcript.where("to", isEqualTo: roomID).order(by: "createdAt").dataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
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
        self.toolBar.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        self.toolBar.setItems([ToolbarItem(customView: self.textView), self.sendBarItem], animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource
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

    @objc private func _send() {
        guard let user: FirebaseAuth.User = Auth.auth().currentUser else { return }
        guard let text: String = self.textView.text else { return }
        let room: Room = self.room
        let transcript: Transcript = Transcript()
        let sender: User = User(id: user.uid, value: [:])
        transcript.from.set(sender)
        transcript.to.set(room)
        transcript.text = text
        room.recentTranscript = transcript.value as! [String : Any]
        let batch: WriteBatch = Firestore.firestore().batch()
        transcript.save(batch, block: nil)
    }

    // MARK: -

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let transcript: Transcript = self.dataSource[indexPath.item]
        if transcript.from.id! == self.sender.uid {
            let cell: MessageViewRightCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageViewRightCell", for: indexPath) as! MessageViewRightCell
            cell.textLabel.text = transcript.text
            return cell
        } else {
            let cell: MessageViewLeftCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageViewLeftCell", for: indexPath) as! MessageViewLeftCell
            cell.textLabel.text = transcript.text
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let transcript: Transcript = self.dataSource[indexPath.item]
        if transcript.from.id! == self.sender.uid {
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

    // MARK: -

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
