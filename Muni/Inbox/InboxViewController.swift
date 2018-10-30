//
//  InboxViewController.swift
//  Sample
//
//  Created by 1amageek on 2018/07/27.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import UIKit
import Pring

extension Muni {
    /**
     A ViewController that displays conversation-enabled rooms.
    */
    open class InboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

        /// The ID of the user holding the DataSource.
        public let userID: String

        /// Room's DataSource
        public private(set) var dataSource: DataSource<RoomType>!

        /// limit The maximum number of rooms to return.
        public let limit: Int

        /// Returns the date format of the message.
        open var dateFormatter: DateFormatter = {
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            dateFormatter.doesRelativeDateFormatting = true
            return dateFormatter
        }()

        public let tableView: UITableView = UITableView(frame: .zero, style: .plain)

        /// Returns a Section that reflects the update of the data source.
        open var targetSection: Int {
            return 0
        }

        public var isLoading: Bool = false {
            didSet {
                if isLoading != oldValue, isLoading {
                    self.dataSource.next()
                }
            }
        }

        // MARK: -

        internal var isFirstFetching: Bool = true

        public init(userID: String, fetching limit: Int = 20) {
            self.userID = userID
            self.limit = limit
            super.init(nibName: nil, bundle: nil)
            self.title = "Message"
            self.dataSource = dataSource(userID: userID, fetching: limit)
        }

        /// You can customize the data source by overriding here.
        ///
        /// - Parameters:
        ///   - userID: Set the ID of the user who is participating in the Room.
        ///   - limit: Set the number of Transcripts to display at once.
        /// - Returns: Returns the DataSource with Query set.
        open func dataSource(userID: String, fetching limit: Int = 20) -> DataSource<RoomType> {
            let options: Options = Options()
            options.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
            return RoomType
                .order(by: "updatedAt", descending: true)
                .where("members", arrayContains: userID)
                .where("isHidden", isEqualTo: false)
                .limit(to: limit)
                .dataSource(options: options)
        }

        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        open override func loadView() {
            super.loadView()
            self.view.addSubview(self.tableView)
            self.tableView.register(UINib(nibName: "InboxViewCell", bundle: nil), forCellReuseIdentifier: "InboxViewCell")
        }

        open override func viewDidLoad() {
            super.viewDidLoad()
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.dataSource
                .on({ [weak self] (snapshot, changes) in
                    guard let tableView: UITableView = self?.tableView else { return }
                    guard let dataSource: DataSource<RoomType> = self?.dataSource else { return }
                    guard let section: Int = self?.targetSection else { return }
                    switch changes {
                    case .initial:
                        tableView.reloadData()
                        self?.didInitialize(of: dataSource)
                    case .update(let deletions, let insertions, let modifications):
                        tableView.beginUpdates()
                        tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: section) }, with: .automatic)
                        tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: section) }, with: .automatic)
                        tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: section) }, with: .automatic)
                        tableView.endUpdates()
                    case .error(let error):
                        print(error)
                    }
                })
        }

        open override func viewWillLayoutSubviews() {
            self.tableView.frame = self.view.bounds
        }

        /// Start listening
        public func listen() {
            self.dataSource.listen()
        }

        // MARK: -

        /// It is called after the first fetch of the data source is finished.
        open func didInitialize(of dataSource: DataSource<RoomType>) {
            // override
        }

        /// Transit to the selected Room. Always override this function.
        /// - parameter room: The selected Room is passed.
        /// - returns: Returns the MessagesViewController to transition.
        open func messageViewController(with room: RoomType) -> MessagesViewController {
            return MessagesViewController(roomID: room.id)
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

        open func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if isFirstFetching {
                self.isFirstFetching = false
                return
            }
            // TODO: スクロールが逆になってる問題
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

        // MARK: -

        open func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }

        open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.dataSource.count
        }

        open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let room: RoomType = self.dataSource[indexPath.item]
            let cell: InboxViewCell = tableView.dequeueReusableCell(withIdentifier: "InboxViewCell", for: indexPath) as! InboxViewCell

            cell.dateLabel.text = self.dateFormatter.string(from: room.updatedAt)

            if let name: String = room.name {
                cell.nameLabel.text = name
            } else if let config: [String: Any] = room.config[self.userID] as? [String: Any] {
                if let nameKey: String = RoomType.configNameKey {
                    cell.nameLabel.text = config[nameKey] as? String
                }
            }

            if let text: String = room.recentTranscript["text"] as? String {
                cell.messageLabel?.text = text
            }

            if room.viewers.contains(self.userID) {
                cell.format = .normal
            } else {
                cell.format = .bold
            }
            return cell
        }

        open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let room: RoomType = self.dataSource[indexPath.item]
            let viewController: MessagesViewController = messageViewController(with: room)
            self.navigationController?.pushViewController(viewController, animated: true)
        }

        open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            // Cancel image loading
        }

        @available(iOS 11.0, *)
        open func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            return nil
        }
    }
}
