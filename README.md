# Manul Monday

An iOS app dedicated to Pallas cats (manuls), designed to create engagement and raise conservation funds through weekly quizzes and daily challenges.

## Overview

Manul Monday is an interactive iOS application that combines education, conservation, and gamification to raise awareness about Pallas cats. Users can:

- Complete weekly quizzes and daily challenges to earn in-app currency
- Adopt and customize virtual Pallas cats with items purchased using earned currency
- Learn about Pallas cat conservation efforts
- Support conservation through optional subscriptions

## Features

- **Weekly Quizzes**: Every Monday, a new quiz is released with questions about Pallas cats, conservation, and related topics
- **Daily Challenges**: Quick daily activities to earn additional currency
- **Virtual Manuls**: Adopt and customize your own virtual Pallas cat
- **Customizable Habitat**: Purchase items to personalize your manul's environment
- **Conservation Information**: Learn about Pallas cats and conservation efforts
- **Premium Subscription**: Optional subscription with exclusive content and benefits

## Project Structure

```
ManulMonday/
├── Sources/
│   ├── App/
│   │   └── ManulMondayApp.swift
│   ├── Models/
│   │   ├── User.swift
│   │   ├── Manul.swift
│   │   ├── Item.swift
│   │   └── Quiz.swift
│   ├── Views/
│   │   ├── Authentication/
│   │   │   ├── LoginView.swift
│   │   │   └── SignUpView.swift
│   │   ├── Home/
│   │   │   └── HomeView.swift
│   │   ├── Manul/
│   │   │   └── ManulView.swift
│   │   ├── Quiz/
│   │   │   └── QuizView.swift
│   │   ├── Store/
│   │   │   └── StoreView.swift
│   │   ├── Profile/
│   │   │   └── ProfileView.swift
│   │   ├── Onboarding/
│   │   │   └── OnboardingView.swift
│   │   └── ContentView.swift
│   └── Services/
│       ├── AuthenticationService.swift
│       ├── QuizService.swift
│       └── StoreService.swift
└── Resources/
    └── GoogleService-Info.plist
```

## Technical Details

- **Platform**: iOS
- **Framework**: SwiftUI
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Architecture**: MVVM (Model-View-ViewModel)
- **Minimum iOS Version**: iOS 15.0

## Firebase Integration

The app uses Firebase for:

- **Authentication**: User sign-up, login, and profile management
- **Firestore Database**: Storing user data, quizzes, manuls, and items
- **Storage**: Storing images for quizzes, manuls, and items
- **Remote Config**: Managing app features and content without updates

## Getting Started

### Prerequisites

- Xcode 14.0 or later
- iOS 15.0 or later
- CocoaPods or Swift Package Manager
- Firebase account

### Installation

1. Clone the repository
   ```
   git clone https://github.com/yourusername/manul-monday.git
   cd manul-monday
   ```

2. Install dependencies
   ```
   pod install
   ```
   or if using Swift Package Manager, open the project in Xcode and let it resolve dependencies

3. Open the project
   ```
   open ManulMonday.xcworkspace
   ```

4. Build and run the project in Xcode

## Firebase Setup

1. Create a new Firebase project at [firebase.google.com](https://firebase.google.com)
2. Add an iOS app to your Firebase project
3. Download the `GoogleService-Info.plist` file and add it to your Xcode project
4. Enable Authentication, Firestore, and Storage in the Firebase console
5. Set up Firestore security rules

## Data Models

### User
- User profile information
- Currency balance
- Owned manuls and items
- Quiz completion history

### Manul
- Type and appearance
- Applied customization items
- Unlock status and cost

### Item
- Type (habitat, accessory, toy, food, background)
- Cost and description
- Unlock status

### Quiz
- Weekly quizzes with questions, images, and answers
- Release and expiration dates
- Currency rewards

## Conservation Partnership

Manul Monday partners with the [Manul Working Group](https://www.manulworkinggroup.org), an international team dedicated to Pallas cat research and conservation.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- The Manul Working Group for conservation information
- [List other acknowledgments here]
