<p align="center">
    <img src="https://raw.githubusercontent.com/ycy-0510/class_todo/refs/heads/dev/assets/img/icon.png" align="center" width="30%">
</p>
<p align="center"><h1 align="center">CLASS_TODO</h1></p>
<p align="center">
	<em>Handle school matters with ease, know your exams and assignments in a second!</em>
</p>
<p align="center">
	<img src="https://img.shields.io/github/license/ycy-0510/class_todo?style=default&logo=opensourceinitiative&logoColor=white&color=0080ff" alt="license">
	<img src="https://img.shields.io/github/last-commit/ycy-0510/class_todo?style=default&logo=git&logoColor=white&color=0080ff" alt="last-commit">
	<img src="https://img.shields.io/github/languages/top/ycy-0510/class_todo?style=default&color=0080ff" alt="repo-top-language">
	<img src="https://img.shields.io/github/languages/count/ycy-0510/class_todo?style=default&color=0080ff" alt="repo-language-count">
</p>
<p align="center"><!-- default option, no dependency badges. -->
</p>
<p align="center">
	<!-- default option, no dependency badges. -->
</p>
<br>

## 🔗 Table of Contents

- [📍 Overview](#-overview)
- [👾 Features](#-features)
- [📁 Project Structure](#-project-structure)
  - [📂 Project Index](#-project-index)
- [🚀 Getting Started](#-getting-started)
  - [☑️ Prerequisites](#-prerequisites)
  - [⚙️ Installation](#-installation)
  - [🤖 Usage](#🤖-usage)
  - [🧪 Testing](#🧪-testing)
- [📌 Project Roadmap](#-project-roadmap)
- [🔰 Contributing](#-contributing)
- [🎗 License](#-license)
- [🙌 Acknowledgments](#-acknowledgments)

---

## 📍 Overview

This is an open-source app project designed to help students manage schoolwork efficiently. The app is built using Dart and Flutter, and it is designed to be user-friendly and easy to navigate. The app features a timetable and list view, submission tracker, push notifications, school announcements, and shared files. The app is perfect for students who want to stay organized and on top of their schoolwork. The app is currently in development, and new features are being added regularly. The app is free to use and open-source, so anyone can contribute to the project. If you are a student looking for a way to stay organized and on top of your schoolwork, this app is for you.

## 👾 Features

Say goodbye to the old days of manually copying class schedules—introducing Shared Contact Book, a collaborative app designed to help students manage schoolwork efficiently.

Key Features:

- Timetable & List View: Organize tasks easily with categorized buttons and lists.
- Submission Tracker: Perfect for class leaders to track submissions, with real-time updates visible to classmates.
- Push Notifications: Stay reminded of important tasks in your preferred way.
- School Announcements: Quickly browse the latest updates from the school website via RSS.
- Shared Files (Coming Soon): Conveniently upload and access shared school documents in one place.

Enhance collaboration with classmates and embrace smart, efficient learning!

---

## 📁 Project Structure

```sh
└── class_todo/
    ├── .github
    │   └── workflows
    ├── LICENSE
    ├── README.md
    ├── analysis_options.yaml
    ├── assets
    │   ├── img
    │   └── logo.png
    ├── ios/
    ├── android/
    ├── web/
    ├── firebase.json
    lib/
    │   ├─ adaptive_action.dart
    │   ├─ firebase_options.dart
    │   ├─ logic/
    │   │  ├─ auth_notifier.dart
    │   │  ├─ calendar_task_notifier.dart
    │   │  ├─ class_table_notifier.dart
    │   │  ├─ connectivety_notifier.dart
    │   │  ├─ date_notifier.dart
    │   │  ├─ deep_link_notifier.dart
    │   │  ├─ exam_activate_notifier.dart
    │   │  ├─ examlist_notifier.dart
    │   │  ├─ form_notifier.dart
    │   │  ├─ google_api_notifier.dart
    │   │  ├─ mixpanel_notifier.dart
    │   │  ├─ notification_notifier.dart
    │   │  ├─ nowtime_notifier.dart
    │   │  ├─ remote_config_notifier.dart
    │   │  ├─ rss_read_notifier.dart
    │   │  ├─ rss_url_notifier.dart
    │   │  ├─ school_notifier.dart
    │   │  ├─ self_number_notifier.dart
    │   │  ├─ submit_notifier.dart
    │   │  ├─ task_notifier.dart
    │   │  ├─ todo_notifier.dart
    │   │  ├─ users_notifier.dart
    │   │  └─ users_number_notifier.dart
    │   ├─ main.dart
    │   ├─ open_url.dart
    │   ├─ page/
    │   │  ├─ class_page.dart
    │   │  ├─ draw_lots.dart
    │   │  ├─ home_page.dart
    │   │  ├─ intro_page.dart
    │   │  ├─ loading_page.dart
    │   │  ├─ login_page.dart
    │   │  ├─ more_view.dart
    │   │  ├─ photo_preview_page.dart
    │   │  ├─ school_view.dart
    │   │  ├─ score_view.dart
    │   │  ├─ setting_page.dart
    │   │  ├─ submit_view.dart
    │   │  ├─ task_view.dart
    │   │  └─ users_page.dart
    │   ├─ provider.dart
    │   └─ theme.dart
    ├── pubspec.lock
    └── pubspec.yaml
```

---

## 🚀 Getting Started

### ☑️ Prerequisites

Before getting started with class_todo, ensure your runtime environment meets the following requirements:

- **Programming Language:** Dart
- **Package Manager:** Pub

### ⚙️ Installation

Install class_todo using one of the following methods:

**Build from source:**

1. Clone the class_todo repository:

```sh
❯ git clone https://github.com/ycy-0510/class_todo
```

2. Navigate to the project directory:

```sh
❯ cd class_todo
```

3. Install the project dependencies:

```sh
❯ pub get
```

### 🤖 Usage

Run class_todo using the following command:

```sh
❯ flutter run
```

---

## 📌 Project Roadmap

- [X] **`Task 1`**: Release for Android and iOS
- [X] **`Task 2`**: Add notification
- [ ] **`Task 3`**: Implement Score Collection feature
- [ ] **`Task 4`**: Implement Personalized Timetable feature

---

## 🔰 Contributing

- **🐛 [Report Issues](https://github.com/ycy-0510/class_todo/issues)**: Submit bugs found or log feature requests for the `class_todo` project.
- **💡 [Submit Pull Requests](https://github.com/ycy-0510/class_todo/blob/main/CONTRIBUTING.md)**: Review open PRs, and submit your own PRs.

<details closed>
<summary>Contributing Guidelines</summary>

1. **Fork the Repository**: Start by forking the project repository to your github account.
2. **Clone Locally**: Clone the forked repository to your local machine using a git client.
   ```sh
   git clone https://github.com/ycy-0510/class_todo
   ```
3. **Create a New Branch**: Always work on a new branch, giving it a descriptive name.
   ```sh
   git checkout -b new-feature-x
   ```
4. **Make Your Changes**: Develop and test your changes locally.
5. **Commit Your Changes**: Commit with a clear message describing your updates.
   ```sh
   git commit -m 'Implemented new feature x.'
   ```
6. **Push to github**: Push the changes to your forked repository.
   ```sh
   git push origin new-feature-x
   ```
7. **Submit a Pull Request**: Create a PR against the original project repository. Clearly describe the changes and their motivations.
8. **Review**: Once your PR is reviewed and approved, it will be merged into the main branch. Congratulations on your contribution!

</details>

<details closed>
<summary>Contributor Graph</summary>
<br>
<p align="left">
   <a href="https://github.com{/ycy-0510/class_todo/}graphs/contributors">
      <img src="https://contrib.rocks/image?repo=ycy-0510/class_todo">
   </a>
</p>
</details>

---

## 🎗 License
This project is protected under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0) License. For more details, refer to the [LICENSE](https://github.com/ycy-0510/class_todo/?tab=Apache-2.0-1-ov-file) file.
