# Event Management System (Realtime)

A real-time Event Management System built with Flutter and Supabase.

## Features
- **Authentication**: Email/Password, Role-based (Admin/User).
- **Events**: Create, Edit, Delete (Admin), View, Mark Interested (User).
- **Real-time**: Instant updates for events and attendees using Supabase Realtime.
- **Media**: Upload multiple images and video with compression.
- **Offline**: Caching with Hive. Works offline and syncs when online.
- **Analytics**: Charts and stats for Admins.

## Setup

1.  **Prerequisites**:
    - Flutter SDK installed.
    - Supabase account.

2.  **Supabase Setup**:
    - Create a new project.
    - Run the SQL queries in `supabase_schema.sql` in the Supabase SQL Editor.
    - Create a storage bucket named `events-media` and set it to public.
    - Get your `URL` and `ANON_KEY` from Project Settings > API.

3.  **App Configuration**:
    - Open `lib/core/constants/app_constants.dart`.
    - Replace `supabaseUrl` and `supabaseAnonKey` with your values.

4.  **Run**:
    ```bash
    flutter pub get
    flutter run
    ```

## Folder Structure
```
lib/
  core/           # Constants, Theme, Utils, Widgets, Router
  features/       # Feature-based modules
    auth/         # Authentication (Domain, Data, Presentation)
    events/       # Event Management (Domain, Data, Presentation)
    analytics/    # Analytics Screen
    media/        # Media Service
  main.dart       # Entry point
```

## State Management
Uses **Riverpod** for dependency injection and state management.
- `NotifierProvider` for view models (Controllers).
- `Provider` for repositories and services.

## Offline Sync
Uses **Hive** to cache events locally.
- **Read**: Tries network first. If fails, reads from Hive.
- **Write**: Writes to network and then updates Hive.
- **Realtime**: Listens to Supabase changes and updates Hive.

## Media Upload
- Uses `image_picker` and `file_picker`.
- Compresses images using `flutter_image_compress` (>300KB).
- Compresses video using `video_compress`.
- Uploads to Supabase Storage.

## Code Generation
- `json_serializable` is used for models.
- `hive_generator` is NOT used to avoid extra setup steps for you; the adapter is manually created in `lib/features/events/data/event_model.g.dart`.
