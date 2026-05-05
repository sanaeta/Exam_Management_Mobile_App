#  Examino: Online Exam Management System

##  Overview
Examino is a full-stack mobile application designed to digitize and streamline the university examination process. Built with Flutter for a cross-platform mobile experience and Laravel for a robust REST API, 
it provides students with a secure, intuitive, and real-time environment to take exams, track results, and manage academic claims.

This project serves as a Graduation Project (PFE), demonstrating a modern decoupled architecture and professional development practices.

##  Architecture

The project follows a decoupled Client-Server model:

### Frontend (Flutter)
Implemented using a Layered Architecture (inspired by Clean Architecture) for maximum maintainability:
- Presentation Layer: Reusable Widgets & Stateful screens  
- Logic Layer: State management and business rules  
- Data Layer: Models (JSON Mapping) & Remote Data Sources (Dio)  
- Infrastructure Layer: Network configuration and global themes  

### Backend (Laravel)
A RESTful API built on the MVC pattern:
- Controllers: Handling API endpoints and business logic  
- Models: Eloquent ORM for MySQL database interaction  
- Security: Middleware-based protection via Laravel Sanctum  

##  Features

###  Secure Authentication
- JWT-like Token authentication using Laravel Sanctum  
- Secure local storage of sessions via SharedPreferences  
- Advanced Password Recovery: Real-time OTP system via SMTP  

###  Exam Engine
- Dynamic dashboard showing "Passés", "Aujourd'hui", and "A venir" exams  
- Real-time asynchronous timer during exams  
- Automatic submission on timeout or manual exit  
- Reliable answer state management  

###  Results & Automated Correction
- Instant automated scoring on server-side  
- Detailed correction view with color-coded results (Correcte/fausse/non répondu)  
- Expandable question details for better UX  

###  Academic Claims System
- Students can contest grades or corrections  
- Real-time email notifications via Mailtrap SMTP  
- Database tracking of claim statuses  

##  Tech Stack
- Mobile: Flutter 3.x & Dart  
- Backend: Laravel 11 (PHP 8.3)  
- Database: MySQL  
- API Client: Dio (Flutter)  
- Security: Laravel Sanctum  
- SMTP Testing: Mailtrap Sandbox  
- Project Management: Jira (Scrum Methodology)  
- Design: Canva  

##  Project Structure (Mono-repo)

```
/mobile-app-flutter-Examino
├── mobile_app_flutter_examino/
│   ├── lib/
│   │   ├── configuration/
│   │   ├── data/
│   │   └── presentation/
├── mobile_app_laravel_examino/
│   ├── app/Http/Controllers/Api/
│   ├── app/Models/
│   └── routes/api.php
└── .gitignore
```

##  Key Concepts Implemented
- Asynchronous programming (async / await)  
- REST API integration with JSON exchange  
- Relational database design (Exams ↔ Questions ↔ Propositions)  
- Reactive state management (setState, FutureBuilder)  
- SMTP email automation system  

##  Usage

### Clone repository
```bash
git clone https://github.com/sanaeta/Exam_Management_Mobile_App.git
```

### Setup Backend (Laravel)
```bash
cd mobile_app_laravel_examino
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

### Setup Frontend (Flutter)
```bash
cd mobile_app_flutter_examino
flutter pub get
```

Update `baseUrl` in `client_reseau.dart` to your local IP, then:
```bash
flutter run
```

##  Author
Sanae Eljaafari
