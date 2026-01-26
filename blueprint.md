
# Project Blueprint

## Overview
This document outlines the design, features, and architectural plan for the Flutter blogging application. The goal is to create a visually appealing, user-friendly, and maintainable application that leverages the JSONPlaceholder API for post data, with secure user authentication provided by Firebase.

## Style and Design
The application follows Material Design 3 principles with a modern and clean aesthetic.

*   **Colors:** A consistent color scheme is used throughout the app.
    *   **Primary Color:** Deep Purple.
    *   **Secondary Color:** Teal.
*   **Typography:** The `google_fonts` package provides clean and readable fonts (`Oswald`, `Roboto`, `Open Sans`).
*   **Layout:** The layout is spacious and intuitive. Cards are used to display posts, providing a clear separation of content.
*   **Iconography:** Material Design icons are used for all actions, including creating, editing, deleting, and logging out.

## Features

### User Authentication
*   **User Registration:** New users can create an account using their email and password.
*   **User Login:** Existing users can sign in to the application.
*   **Logout:** Authenticated users can log out via a confirmation dialog.
*   **Auth-aware Routing:** The app automatically redirects unauthenticated users to the login screen.

### Post Management
*   **Post List:** Displays a list of all posts from the JSONPlaceholder API. Users can pull-to-refresh the list.
*   **Post Detail:** Displays the full details of a selected post.
*   **Create/Edit Post:** Authenticated users can create new posts and edit existing ones through a unified detail screen.
*   **Delete Post:** Authenticated users can delete posts after a confirmation dialog.

## Architecture
*   **State Management:** `flutter_riverpod` is used for robust and scalable state management.
*   **Routing:** `go_router` provides declarative, URL-based navigation and handles authentication-based redirects.
*   **Authentication:** `firebase_auth` handles all user authentication, including user creation and sign-in.
*   **Database:** `cloud_firestore` is used to store user information.
*   **Security:** `firebase_app_check` is configured to protect backend resources.
*   **API Service:** A dedicated service class handles all interactions with the JSONPlaceholder API.
*   **Models:** Data models represent the data retrieved from the API.

## Current Plan
*   **Implement User Authentication:** Add registration, login, and logout functionality using Firebase Auth. **(Complete)**
*   **Secure the Application:** Configure App Check and implement auth-aware routing. **(Complete)**
*   **Improve UI and Error Handling:** Refine the UI for login/register screens and ensure all loading and error states are handled gracefully. **(Complete)**
