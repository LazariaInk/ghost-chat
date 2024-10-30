# GhostChat

Secure Chat - Decentralized, Encrypted Peer-to-Peer Messaging
Secure Chat is a cross-platform, peer-to-peer messaging app with end-to-end encryption that prioritizes privacy. Users create private channels by sharing an offline key, ensuring conversations remain private and inaccessible to unauthorized parties. Built with cross-platform tools, Secure Chat is accessible on both Android and iOS.
Features
- **End-to-End Encryption**: Messages are encrypted with a shared key known only to the participants, ensuring absolute confidentiality.
- **Private Channels**: Users can create dedicated channels, each with a unique name and access key. Access to the channel is granted only by sharing the key offline.
- **No Centralized Server**: Secure Chat operates without a centralized server for storing messages. Instead, messages are transmitted peer-to-peer and decrypted only by the intended recipient.
- **Account-Free Access**: No need for accounts, usernames, or passwords. Access is managed through offline key exchange.
How It Works
1. **Create a Channel**: Users start by creating a channel and assigning it a name and encryption key.
2. **Share the Key Offline**: The channel key is shared offline (e.g., in person) to prevent unauthorized access.
3. **Exchange Encrypted Messages**: Once connected, users can exchange messages encrypted with the channel key, which only participants can decrypt.
4. **Simple Channel Management**: Add, edit, or delete channels from the main menu with a user-friendly interface.
Technologies
Secure Chat is built using cross-platform technologies to ensure compatibility on both Android and iOS:
- **Flutter**: For a responsive and smooth user interface, running seamlessly on both Android and iOS.
- **Dart**: The programming language used with Flutter for UI and logic.
- **Crypto (Dart Package)**: Used for implementing AES-256 encryption, providing strong end-to-end encryption for each channel.
- **P2P Communication**: Leveraging `flutter_p2p` or similar plugins for local network discovery and peer-to-peer communication, ensuring no data is sent through a central server.
Getting Started
Prerequisites
- **Flutter SDK**: Install the Flutter SDK to enable cross-platform development.
- **Android Studio or Xcode**: For testing and deploying on Android and iOS devices.
Installation
Clone the repository and set up dependencies:
```bash
git clone https://github.com/username/secure-chat.git
cd secure-chat
flutter pub get
```
Running the App
1. **Connect a Device or Emulator**: Ensure that either an Android or iOS device/emulator is connected.
2. **Run the Application**: Start the app using the following command:

```bash
flutter run
```
3. **Configure Permissions**: Ensure the app has permissions for local network access and P2P connections on both Android and iOS.
Usage
- **Adding Channels**: In the main menu, select "Add New Channel," enter a channel name, and assign an encryption key.
- **Editing Channels**: Tap an existing channel to edit the name or encryption key.
- **Deleting Channels**: Select a channel, then choose the delete option to remove it from the list.
Code Overview
- **Channel Management**: The `Channel` class represents each chat channel with a name and key, visible in the main channel list.
- **Encryption**: Messages in each channel are encrypted using AES-256 for confidentiality.
- **Flutter Widgets**: The UI is built with Flutter, ensuring a consistent experience on both Android and iOS.
Future Enhancements
- **Self-Destructing Messages**: An option to delete messages after a specified time.
- **Advanced Group Chat**: Adding more robust group communication features.
- **Key Rotation**: Periodically refreshing encryption keys for added security.
Contributing
Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a new branch for your feature or bug fix (`git checkout -b feature/YourFeatureName`).
3. Commit your changes (`git commit -m 'Add Your Feature'`).
4. Push to the branch (`git push origin feature/YourFeatureName`).
5. Create a pull request with a description of your changes.
License
This project is open-source and available under the [MIT License](LICENSE).
Acknowledgments
Thanks to the contributors and the open-source community for making Secure Chat possible!
