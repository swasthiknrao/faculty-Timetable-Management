# faculty-Timetable-Management

A comprehensive Flutter-based College Management System designed to streamline administrative tasks, faculty management, and timetable scheduling in educational institutions.

## Features

### Admin Dashboard
- Faculty Management (Add, Edit, Delete faculty members)
- Timetable Management
- Class Management
- Department-wise faculty organization
- Settings and System Preferences

### Faculty Dashboard
- Personal Schedule View
- Profile Management
- Unavailability Management
- Class Schedule Management
- Dark/Light Theme Support

### Authentication & Security
- Secure Login System
- Role-based Access Control
- Password Management
- OTP Verification

### Additional Features
- Responsive Design
- Theme Customization
- Profile Image Management
- Real-time Schedule Updates

## Prerequisites

Before running this project, ensure you have the following installed:
- Flutter (Latest Version)
- Dart SDK
- Android Studio / VS Code
- Git

## Dependencies

This project relies on several Flutter packages:yaml
dependencies:
flutter:
sdk: flutter
provider: ^6.0.0
image_picker: ^1.0.0
shared_preferences: ^2.0.0
permission_handler: ^10.0.0





## Installation

1. Clone the repository
    git clone https://github.com/yourusername/college-management-system.git

2. Navigate to project directory
  cd college-management-system
  
3. Install dependencies
    flutter pub get

4. Run the app
   flutter run



## Project Structure
ib/faculty/faculty_profile_page.dart                                                                         
lib/                                                                     
├── admin/                                                                   
│ ├── faculty_management.dart                                             
│ ├── timetable_management.dart                                                      
│ └── settings_page.dart                                                     
├── faculty/                                                        
│ ├── dashboard.dart                                                                  
│ └── settings_page.dart                                                                       
├── models/                                                         
│ └── timetable_entry.dart                                                        
├── utils/                                                                    
│ ├── theme_provider.dart                                                               
│ └── responsive_util.dart                                                                  
└── main.dart                                                           




## Configuration

The project uses several configuration files:
- Theme configuration in `lib/utils/theme_provider.dart`
- Responsive layout settings in `lib/utils/responsive_util.dart`
- Lab hours configuration in `lib/utils/lab_hours_provider.dart`

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Contact

Your Name - nraoswasthik2004@gmail.com
Project Link: https://github.com/swasthiknrao/faculty-Timetable-Management

## Acknowledgments

- Flutter Team for the amazing framework
- Contributors and testers
- College administration for requirements and feedback
