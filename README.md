
# **Ghost Chat - End-to-End Encrypted Chat Application (PoC) 📱🔐**

---

## **📘 Overview**
**Ghost Chat** is a **secure chat application** that uses **End-to-End Encryption (E2EE)**. The application ensures that messages are encrypted on the client-side and only decrypted on devices that have the correct secret key. 

The app is built using **Flutter** for the client-side interface and **Firebase** for user authentication and message storage. Messages are encrypted before being stored in Firestore, ensuring that only users with the correct secret key can decrypt and read them. The secret keys are **never shared with the server** and are stored locally using **SharedPreferences**.

This PoC is fully deployed as an APK for **Android devices**.
**To download Android version check this link:**
https://github.com/LazariaInk/ghost-chat/releases/download/V1/app-release.apk

---

## **📱 Application Structure**

### **1️⃣ Login Screen**
- Users can log in using **Google Sign-In** (via Firebase Authentication).
- Upon successful login, the user's information (name, email) is stored in Firestore under the **/users/{UID}** document.
- The user's **UID** is used to identify them in Firestore.

### **2️⃣ Main Screen**
- Displays a **list of channels** that the user has created or joined.
- Users can:
  - **Join an existing channel** by entering the channel name and the secret key.
  - **Create a new channel** with a custom channel name and a secret key.
- There is also a **Floating Action Button (FAB)** to create or join a new channel.

### **3️⃣ Add Channel Screen**
- **Two tabs**:
  - **Create Channel**:
    - Users provide a **channel name** and a **secret key**.
    - The secret key is stored locally using **SharedPreferences**.
    - The channel is created in Firestore, but the secret key is **never stored on the server**.
  - **Join Channel**:
    - Users enter an **existing channel name** and the **secret key**.
    - If the key is incorrect, messages will be unreadable.
    - Messages encrypted with the wrong key will be **unreadable to other users** as well.

### **4️⃣ Chat Screen**
- Users can **send and receive encrypted messages**.
- Messages are encrypted locally before being sent to Firestore.
- Messages are decrypted on the client-side using the **secret key stored in SharedPreferences**.
- If the key is incorrect, the user will see garbled (unreadable) messages.

---

## **📦 Firestore Database Structure**

```
/users/{userId}
  - name: "User Name"
  - email: "user@example.com"

channels
  └── {channelName} (document)
       ├── name: "Channel Name"
       ├── createdAt: (Firestore timestamp)
       └── encryptionAlgorithm: "AES"

channels/{channelName}/messages
  └── {messageId} (document)
       ├── content: "4MTjdKXtV0YHwcuPlHjayQ==" (Encrypted message)
       ├── senderId: "userUID"
       ├── senderName: "User Name"
       └── timestamp: (Firestore timestamp)
```

---

## **🔐 Security Design**

### **1️⃣ End-to-End Encryption (E2EE)**
- **Encryption Algorithm**: **AES-256**
- **Key Storage**: 
  - The secret keys are **only stored locally** on the user's device using **SharedPreferences**.
  - The secret keys are never sent or stored on the server.
- **Encryption Process**:
  - Before sending a message, it is encrypted locally using the **AES-256 secret key**.
  - The encrypted message is then sent to Firestore.
  - When a message is received, the app decrypts it locally using the **secret key from SharedPreferences**.

### **2️⃣ Access Control**
- Each user is authenticated using **Google Sign-In** via Firebase Authentication.
- Each user is assigned a unique **User ID (UID)**, which is used to identify and associate them with their messages.
- To join a channel, users must know both the **channel name** and the **correct secret key**.
- If the user enters the incorrect key, the messages will remain **unreadable**.

---

## **🚀 Deployment**
- The application is packaged as an **APK** for Android devices.
- The APK can be installed on physical Android devices or tested using an **Android emulator**.

---

## **📚 Technologies Used**
| **Technology**             | **Purpose**                                      |
|----------------------------|--------------------------------------------------|
| **Flutter**                 | Cross-platform development for Android           |
| **Firebase Authentication** | User login using **Google Sign-In**              |
| **Firebase Firestore**      | Cloud storage for channels and encrypted messages|
| **AES Encryption**          | End-to-End encryption (E2EE)                     |
| **SharedPreferences**       | Local storage of encryption keys on the client-side|

---

## **🔄 Application Flow**

1. **User Authentication**
   - Users log in using **Google Sign-In**.
   - The user's **UID** is stored locally to identify the user in Firestore.
   
2. **Main Screen**
   - Users see a list of their channels.
   - Users can **create a new channel** or **join an existing channel**.

3. **Channel Creation**
   - Users provide a **channel name** and a **secret key**.
   - The secret key is stored locally using **SharedPreferences**.
   - A new **channel document** is created in Firestore.

4. **Join Channel**
   - Users enter a channel name and secret key.
   - The secret key is stored locally.
   - If the key is incorrect, messages in the chat will be garbled.

5. **Chat**
   - Users can send and receive messages in the channel.
   - Messages are encrypted before being sent to Firestore.
   - Messages are decrypted using the secret key from **SharedPreferences**.
   - If the key is incorrect, the messages will be unreadable.

---

## **📋 How to Run**

### **1️⃣ Prerequisites**
- **Flutter SDK** installed ([Installation Guide](https://flutter.dev/docs/get-started/install)).
- **Firebase Project** with Firestore and Authentication enabled.
- **google-services.json** in the **android/app** directory.

### **2️⃣ Install Dependencies**
Run the following command to install Flutter dependencies:
```bash
flutter pub get
```

### **3️⃣ Run on Android Emulator or Physical Device**
Run the following command to start the app on a connected device or emulator:
```bash
flutter run
```

### **4️⃣ Build APK**
To generate the APK for Android, run:
```bash
flutter build apk --release
```
The APK will be available in the **build/app/outputs/flutter-apk** directory.

---

## **💡 Future Improvements**
- **Media Attachments**: Support for sending images, videos, and files.
- **Invite Links**: Generate invite links to share encrypted access to channels.
- **Read Receipts**: Show when messages are read by other users.
- **Multi-Device Support**: Allow users to access the same channels on multiple devices.

---

## **📧 Contact**
For questions, issues, or feature requests, please create an issue in the repository or reach out to the development team.

---
