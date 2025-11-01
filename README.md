# CashBack - Personal Finance Management App

A comprehensive Flutter application designed to help users manage their personal finances, track transactions, set financial goals, and simulate investment scenarios. Built with a clean, intuitive interface and robust local database storage.

## 📱 Features

### 🔐 User Authentication
- Secure user registration and login
- Profile management with editable user information
- Welcome screen with app introduction

### 💰 Transaction Management
- Add, view, edit, and delete financial transactions
- Support for income and expense tracking
- Transaction categorization and detailed records
- Choose between different transaction types

### 🎯 Goal Management
- Set and track financial goals
- Goal progress monitoring
- Goal history and completion tracking
- Add, edit, and manage multiple goals simultaneously

### 📊 Investment Simulator
- Create investment simulation scenarios
- Interactive charts showing projected growth
- Support for CAGR (Compound Annual Growth Rate) calculations
- Multiple simulation management with swipe navigation
- Detailed investment parameters (initial investment, monthly contributions, time periods)

### 💡 Savings Recommendations
- Personalized savings suggestions based on user data
- AI-powered recommendations using financial datasets
- Data-driven insights for better financial planning

### 📈 Personal Finance Dashboard
- Comprehensive financial overview
- Transaction summaries and analytics
- Visual representations of financial data

### ℹ️ Information Hub
- Educational content about personal finance
- Tips and best practices
- Financial literacy resources

## 🛠️ Technical Stack

- **Framework**: Flutter
- **Language**: Dart
- **Database**: SQLite (via sqflite package)
- **Charts**: FL Chart for data visualization
- **State Management**: Stateful widgets with local state
- **UI Components**: Material Design 3
- **Data Processing**: CSV parsing for financial datasets
- **Financial Calculations**: Custom algorithms for investment projections

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  sqflite: ^2.3.3+1
  path: ^1.9.0
  intl: ^0.18.1
  fl_chart: ^0.65.0
  yahoofin: ^0.0.8
  csv: ^5.1.1
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (version 3.4.0 or higher)
- Dart SDK (version 3.4.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Android/iOS emulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Darthy566/CashBack.git
   cd cashback
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS (on macOS):**
```bash
flutter build ios --release
```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point and routing
├── app_colors.dart              # Centralized color constants
├── database_helper.dart         # SQLite database operations
├── persona_service.dart         # AI recommendation service
├── widgets/
│   └── gradient_text_field.dart # Custom text field widget
├── welcome_screen.dart          # App introduction screen
├── login_screen.dart            # User authentication
├── create_account_screen.dart   # User registration
├── home_screen.dart             # Main dashboard
├── profile_screen.dart          # User profile management
├── personal_finance_screen.dart # Financial overview
├── transaction_*.dart           # Transaction management screens
├── goal_*.dart                  # Goal management screens
├── investment_simulator_screen.dart # Investment simulation
├── simulation_create_screen.dart    # Create new simulations
├── savings_recommendation_screen.dart # AI recommendations
└── information_screen.dart      # Educational content

assets/
└── synthetic_personal_finance_dataset.csv # Financial dataset for AI
```

## 🎨 Design System

### Colors
- **Primary Green**: `#4CAF50` - Main brand color
- **Light Green**: `#8BC34A` - Secondary green
- **Dark Green**: `#388E3C` - Dark green accents
- **Background**: `#F5F5F5` - Light grey background

### Typography
- **Font Family**: Roboto
- **Consistent text styling** across all screens

### UI Components
- Material Design 3 components
- Custom gradient backgrounds
- Consistent spacing and padding
- Responsive design for different screen sizes

## 🗄️ Database Schema

### Users Table
- User authentication and profile information
- Personal details and preferences

### Transactions Table
- Income and expense records
- Categorization and timestamps
- User associations

### Goals Table
- Financial goal definitions
- Progress tracking
- Completion status

### Simulations Table
- Investment simulation parameters
- Projected values and calculations
- User-specific scenarios

## 🔧 Key Features Implementation

### Investment Calculations
The app implements compound interest calculations using the formula:
```
Future Value = Initial Investment × (1 + CAGR)^years + Monthly Contribution × [(1 + CAGR)^years - 1] / CAGR
```

### Chart Visualization
- Interactive line charts for investment projections
- Touch-enabled tooltips with detailed information
- Year-based axis labels and currency formatting

### Data Persistence
- Local SQLite database for offline functionality
- Secure data storage with proper relationships
- Efficient querying and data management

## 🤖 AI-Powered Features

### Savings Recommendations
- Utilizes synthetic financial datasets
- Machine learning-based suggestions
- Personalized recommendations based on user behavior

## 📱 Screenshots & UI Flow

1. **Welcome Screen** - App introduction and branding
2. **Authentication** - Login/Register flow
3. **Home Dashboard** - Main navigation hub
4. **Transaction Management** - Add/view/edit financial transactions
5. **Goal Setting** - Create and track financial goals
6. **Investment Simulator** - Interactive investment projections
7. **Profile Management** - User settings and information

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

## 📋 TODO & Future Enhancements

- [ ] Cloud backup and synchronization
- [ ] Multi-currency support
- [ ] Advanced analytics and reporting
- [ ] Budget planning features
- [ ] Integration with financial APIs
- [ ] Push notifications for goals and reminders
- [ ] Dark mode theme
- [ ] Biometric authentication

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Darthy566** - *Initial work and development*

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for UI inspiration
- Open source community for various packages and tools

---

**Made with ❤️ using Flutter**
