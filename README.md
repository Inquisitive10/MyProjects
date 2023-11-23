# task_manager
Task Manager is a simple Flutter app that allows users to manage tasks using Back4App as a backend and the Parse SDK for communication.

## Getting Started
Features
=> View a list of tasks
=> Add new tasks
=> Edit existing tasks
=> Delete selected tasks
=> View detailed information for a specific task

# Setup
# Prerequisites
Before running the app, make sure you have the following:
=>Flutter installed on your machine.
=>Back4App account: Sign up for a free account.

# Configuration
=> Clone the repository:
git clone https://github.com/yourusername/task-manager-flutter.git
=> Navigate to the project directory:
    cd task-manager-flutter
=> Install dependencies:
    flutter pub get
=> Open the main.dart file and replace the following variables with your Back4App credentials:
    final keyApplicationId = 'YOUR_APPLICATION_ID';
    final keyClientKey = 'YOUR_CLIENT_KEY';
    final keyParseServerUrl = 'YOUR_PARSE_SERVER_URL';

# Run the App
=> Run the app on an emulator or physical device:
    flutter run
The app should now be running on your device.

# Usage
=> Launch the app to view the list of tasks.
=> Add a new task by clicking the "Add" button.
=> Edit a task by selecting the checkbox and clicking the "Edit" button.
=> Delete selected tasks by clicking the "Delete" button.
=> View detailed information for a task by clicking on the task in the list.
