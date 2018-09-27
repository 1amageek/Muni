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
    open class InboxViewController: UITableViewController {

        /// The ID of the user holding the DataSource.
        public let userID: String

        /// Room's DataSource
        public let dataSource: DataSource<RoomType>

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
            let options: Options = Options()
            options.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
            self.dataSource = RoomType
                .where("members", arrayContains: userID)
                // FIXME: Index is not valid
//                .order(by: "updatedAt", descending: true)
                .limit(to: limit)
                .dataSource(options: options)
            super.init(nibName: nil, bundle: nil)
            self.title = "Message"
        }

        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        open override func loadView() {
            super.loadView()
            self.tableView.register(UINib(nibName: "InboxViewCell", bundle: nil), forCellReuseIdentifier: "InboxViewCell")
        }

        open override func viewDidLoad() {
            super.viewDidLoad()
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

        /// Start listening
        public func listen() {
            self.dataSource.listen()
        }

        // MARK: -

        /// It is called after the first fetch of the data source is finished.
        open func didInitialize(of dataSource: DataSource<RoomType>) {
            // override
        }

        // MARK: -

        open override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }

        open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.dataSource.count
        }

        open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

        open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let room: RoomType = self.dataSource[indexPath.item]
            let viewController: MessagesViewController = messageViewController(with: room)
            self.navigationController?.pushViewController(viewController, animated: true)
        }

        open override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            // Cancel image loading
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

        open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
    }
}
