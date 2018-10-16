# Muni
Chat framework

<img src="https://github.com/1amageek/Muni/blob/master/sample.gif" width="500">

# Feature 🎊

☑️ **Serverless - Firebase Cloud Firestore**<br>
☑️ **Realtime**<br>
☑️ **Customizable**<br>
☑️ **Type Safe**<br>
☑️ **Multi Media**

#### Media
- Text
- Image
- Video
- Audio
- Location
- Sticker
- ImageMap


# Installation

`pod 'Muni'` add to your Podfile

```
pod install
```

`GoogleService-Info.plist` add to your Project

# Usage

## Prepare three documents for cloud firestore.
`UserProtocol` `RoomProtocol` `TranscriptProtocol` create document conforming to each protocol.

``` swift
@objcMembers
class User: Object, UserProtocol {
    var name: String?
    var thumbnailImage: File?
}
```

``` swift
@objcMembers
class Room: Object, RoomProtocol {
    dynamic var name: String?
    dynamic var thumbnailImage: File?
    dynamic var members: Set<String> = []
    dynamic var recentTranscript: [String: Any] = [:]
    dynamic var config: [String: Any] = [:]
}
```

``` swift
@objcMembers
class Transcript: Object, TranscriptProtocol {
    dynamic var to: Relation<Room> = .init()
    dynamic var from: Relation<User> = .init()
    dynamic var text: String?
    dynamic var image: File?
    dynamic var video: File?
    dynamic var audio: File?
    dynamic var location: GeoPoint?
    dynamic var sticker: String?
    dynamic var imageMap: [File] = []
}
```

## Override two ViewControllers

```swift
class MessageViewController: Muni<User, Room, Transcript>.MessagesViewController {

    var sendBarItem: ToolbarItem!

    override var senderID: String? {
        return Auth.auth().currentUser!.uid
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendBarItem = ToolbarItem(title: "Send", target: self, action: #selector(send))
        self.toolBar.setItems([ToolbarItem(customView: self.textView), self.sendBarItem], animated: false)
        
        // Start
        self.listen()
    }

    override func transcript(willSend transcript: Transcript) -> Bool {
        guard let text: String = self.textView.text else { return false }
        if text.isEmpty { return false }
        transcript.text = text
        self.textView.text = nil
        return true
    }
}
```

```swift
class BoxViewController: Muni<User, Room, Transcript>.InboxViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Start
        self.listen()
    }

    override func messageViewController(with room: Room) -> Muni<User, Room, Transcript>.MessagesViewController {
        return MessageViewController(roomID: room.id)
    }
}
```

### Build

> Muni internally uses Firestore Query.
> An error occurs if there is no Index in Firestore. You can create an Index by accessing the URL on the console.
