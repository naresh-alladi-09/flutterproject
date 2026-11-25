# 🎓 StudyFlow - Student Task & Study Management App

A modern, production-grade Flutter application built specifically for students to manage academic assignments, track exam preparations, organize weekly class timetables, stay focused with an integrated Pomodoro timer, and jot down lecture notes.

Built with **Flutter**, **Material 3 Design**, **Provider** state management, and **Local Storage Persistence**.

---

## 🌟 Key Features

### 1. 📊 Interactive Academic Dashboard
- **Daily Study Pulse**: Real-time progress ring tracking completed vs. pending tasks for today.
- **Quick Statistics**: Live counters for tasks due today, overdue alerts, pending assignments, and total completed.
- **Upcoming Deadlines Carousel**: Horizontal countdown cards highlighting urgent assignments with priority color indicators.
- **Today's Class Schedule Preview**: Instant glance at today's lectures, rooms, and professors.
- **Theme Toggle**: 1-tap switch between Light and Dark mode.

### 2. 📝 Full Task & Assignment Management
- **Filter Tabs**: Filter by *All*, *Today*, *Upcoming*, *Completed*, and *Overdue*.
- **Multi-criteria Filtering & Sorting**: Filter by Course and Priority level (Urgent, High, Medium, Low); sort by due date, priority, or title.
- **Instant Search**: Search across assignment titles, descriptions, and subject names in real time.
- **Subtasks / Checklist Builder**: Break complex projects into manageable steps with automatic completion percentage calculation.
- **Task Types & Badges**: Categorize as *Assignment*, *Exam Prep*, *Project*, *Homework*, *Reading*, or *Personal*.
- **Swipe-to-Delete**: Smooth dismissible action with confirmation alert.

### 3. ⏱️ Integrated Pomodoro Focus Timer
- **Customizable Intervals**: Focus Mode (25 min), Short Break (5 min), Long Break (15 min).
- **Task Association**: Link any active homework or study assignment to your focus session. Completing a focus block automatically updates your completed session counter!
- **Ambient Soundscapes**: Select ambient sound simulation (Gentle Rain 🌧️, Campus Library 📚, Coffee Shop ☕, White Noise 🍃, Off).
- **Study Minutes Tracker**: Automatically tallies cumulative daily study minutes.

### 4. 📅 Weekly Timetable & Class Schedule
- **Day-by-Day Strip**: Switch seamlessly between Monday to Sunday.
- **Detailed Class Cards**: Start & End times, Room/Lab number, Instructor name, and custom course color accents.
- **Full CRUD**: Add, edit, or remove lecture slots anytime.

### 5. 📚 Course & Subject Directory
- **Course Profiles**: View enrolled courses (e.g. CS101, MATH201, PHYS102) with custom color tags.
- **Subject Analytics**: See total assignments, pending tasks, and completion percentage per subject.
- **Direct Task Creation**: Add tasks directly pre-linked to any course.

### 6. 💡 Quick Study Notes & Brain Dump
- Capture formula sheets, exam tips, and lecture highlights.
- **Pin to Top**: Keep critical formula sheets pinned.
- **Course Linking & Color Coding**: Organize notes by course.

### 7. 💾 Robust Local Persistence & Demo Seed Data
- Powered by `SharedPreferences` with JSON serialization.
- Comes pre-loaded with realistic sample courses, assignments, weekly schedule, and notes so the app is instantly ready to explore!
- Option to restore default demo data at any time from Settings.

---

## 🏗️ Project Architecture

```
lib/
├── main.dart                               # App entry point, MultiProvider setup & theme configuration
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                 # Color palette (Light, Dark, Priorities, Courses)
│   │   └── app_strings.dart                # App strings & labels
│   ├── theme/
│   │   └── app_theme.dart                  # Material 3 light & dark theme definitions
│   └── services/
│       └── storage_service.dart            # Local persistence & initial demo data seeding
├── models/
│   ├── task_model.dart                     # Task & Subtask data structures with JSON serialization
│   ├── course_model.dart                   # Course/Subject data model
│   ├── schedule_model.dart                 # Class timetable entry model
│   └── note_model.dart                     # Study note model
├── providers/
│   ├── task_provider.dart                  # Task business logic, filters, sorting, and metrics
│   ├── course_provider.dart                # Course list management
│   ├── schedule_provider.dart              # Weekly timetable state
│   ├── note_provider.dart                  # Notes management & filtering
│   ├── timer_provider.dart                 # Pomodoro state machine & focus session logger
│   └── theme_provider.dart                 # Dynamic ThemeMode switcher (Light / Dark / System)
├── screens/
│   ├── main_navigation_screen.dart         # Bottom Navigation Bar shell
│   ├── dashboard/
│   │   ├── dashboard_screen.dart           # Dashboard overview
│   │   └── widgets/                        # Stat cards, progress banner, deadline cards
│   ├── tasks/
│   │   ├── tasks_screen.dart               # Task list with search & chips
│   │   ├── task_detail_screen.dart         # Deep dive into task & subtasks
│   │   ├── add_edit_task_screen.dart       # Comprehensive task creation/edit form
│   │   └── widgets/                        # TaskCard, SubtaskItemWidget, TaskFilterSheet
│   ├── timetable/
│   │   ├── timetable_screen.dart           # Day-by-day timetable
│   │   └── add_class_dialog.dart           # Add/edit lecture schedule dialog
│   ├── timer/
│   │   └── pomodoro_screen.dart            # Circular countdown Pomodoro timer
│   ├── courses/
│   │   ├── courses_screen.dart             # Courses list
│   │   ├── course_detail_screen.dart       # Course tasks & completion
│   │   └── add_edit_course_dialog.dart     # Course editor dialog
│   ├── notes/
│   │   ├── notes_screen.dart               # Notes gallery
│   │   └── add_edit_note_screen.dart       # Note editor
│   └── settings/
│       └── settings_screen.dart            # Student profile, theme toggle, and data reset
└── widgets/
    ├── priority_badge.dart                 # Color-coded priority badges
    ├── task_type_badge.dart                # Category icon badges
    ├── empty_state_view.dart               # Friendly empty state placeholders
    └── custom_button.dart                  # Reusable action buttons
```

---

## 🚀 Getting Started & How to Run

### 1. Prerequisites (Flutter SDK)
If Flutter is not yet installed on your system:
1. Download Flutter SDK from [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install/windows).
2. Extract the zip to `C:\src\flutter`.
3. Add `C:\src\flutter\bin` to your **User / System PATH** environment variables.
4. Verify by opening a new terminal and running:
   ```bash
   flutter doctor
   ```

### 2. Install Project Dependencies
In the root directory of this project (`flutter project`):
```bash
flutter pub get
```

### 3. Launch the Application

#### Run on Web (Chrome):
```bash
flutter run -d chrome
```

#### Run on Windows Desktop:
```bash
flutter run -d windows
```

#### Run on Android Emulator or Physical Device:
```bash
flutter run -d android
```

#### Run on iOS (macOS only):
```bash
flutter run -d ios
```

---

## 🧪 Running Automated Tests

Run the test suite to verify widgets and dashboard integrity:
```bash
flutter test
```

---

## 🎨 Theme & Accessibility
- Material Design 3 guidelines with rounded geometry (`BorderRadius.circular(16)`).
- Full contrast compliance for both Light (`#F8FAFC`) and Dark (`#0F172A`) modes.
- Responsive layout adapting to phone screens, tablets, and desktop/web widths.

