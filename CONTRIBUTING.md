# Contributing to Manul Monday

Thank you for your interest in contributing to Manul Monday! This document provides guidelines and instructions for contributing to this project.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone.

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with the following information:

- A clear, descriptive title
- Steps to reproduce the bug
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Device information (iOS version, device model)
- Any additional context

### Suggesting Features

We welcome feature suggestions! To suggest a feature:

1. Check if the feature has already been suggested or implemented
2. Create an issue with a clear description of the feature
3. Explain why this feature would be beneficial
4. Provide examples of how the feature might work

### Pull Requests

1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature-name`)
3. Make your changes
4. Test your changes thoroughly
5. Commit your changes (`git commit -m 'Add some feature'`)
6. Push to the branch (`git push origin feature/your-feature-name`)
7. Open a Pull Request

#### Pull Request Guidelines

- Follow the existing code style
- Update documentation as needed
- Add tests for new features
- Ensure all tests pass
- Keep pull requests focused on a single feature or bug fix

## Development Setup

1. Clone the repository
2. Run `./setup.sh` to install dependencies
3. Open `ManulMonday.xcworkspace` in Xcode

## Project Structure

```
ManulMonday/
├── Sources/
│   ├── App/
│   ├── Models/
│   ├── Views/
│   └── Services/
└── Resources/
```

- **App**: Contains the main app entry point
- **Models**: Data models and structures
- **Views**: SwiftUI views organized by feature
- **Services**: Services for Firebase and other functionality
- **Resources**: Assets, configuration files, etc.

## Coding Style

- Follow Swift's official style guide
- Use meaningful variable and function names
- Write comments for complex logic
- Keep functions small and focused
- Use SwiftUI's declarative syntax appropriately

## Testing

- Write unit tests for models and services
- Write UI tests for critical user flows
- Run tests before submitting a pull request

## Documentation

- Document public APIs and complex functions
- Update README.md when adding significant features
- Include comments explaining non-obvious code

## Questions?

If you have any questions about contributing, feel free to open an issue asking for clarification.

Thank you for contributing to Manul Monday and helping support Pallas cat conservation!
