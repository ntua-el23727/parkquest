# 🚗 ParkQuest

## Overview

**ParkQuest** is a smart parking management application that helps users save, remember, and navigate back to their parked car location. The app integrates with Google Maps to provide navigation, allows users to add notes and photos to their parking spots, and has a community that shares parking spots in the app. Users can earn points through parking activities and unlock rewards like free coffee, gift cards, and parking vouchers.

## Features / Χαρακτηριστικά

### Core Features
- **Save Parking Location**: Instantly save your current location with GPS coordinates
- **Find My Car**: Get navigation back to your parked vehicle using Google Maps Routes API
- **Parking Notes**: Add custom notes about your parking spot (e.g., "Level 3, near elevator")
- **Photo Attachment**: Take a photo of your parking location for easy visual reference
- **Shared Parking Spots**: Discover available parking spots shared by other users nearby
- **Rewards System**: Earn points for parking activities and unlock rewards
- **Activity History**: Track all your parking events with detailed history
- **User Profile**: Manage your account, view points, and access rewards

---

## 📱 Οδηγίες Εγκατάστασης / Installation Instructions

### Προαπαιτούμενα / Prerequisites
- **Flutter SDK**: Version 3.10.1 ή νεότερο / or newer
- **Android Studio** ή **VS Code** με Flutter plugin
- **Android Device** ή **Emulator** **με Google Play Services** 
- **Google Maps API Key**

### Βήματα Εγκατάστασης / Installation Steps

#### 1. Λήψη του Project
```bash
# Clone the repository (if available on GitHub)
git clone [repository-url]

# Ή download και extract το ZIP file από το repository
```

#### 2. Απόκτηση Google Maps API Key

Η εφαρμογή χρειάζεται Google Maps API Key για να λειτουργήσει. Η έκδοση του γίνεται μέσω του [Google Cloud Console](https://console.cloud.google.com/)

#### 3. Ρύθμιση API Keys

1. Αντιγράψτε το αρχείο `.env.example` σε `.env`:
```bash
cp .env.example .env
```

2. Ανοίξτε το `.env` και προσθέστε το API key σας:
```env
GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE
```

#### 4. Εγκατάσταση Dependencies
```bash
cd parkquest
flutter pub get
```

#### 5. Εκτέλεση της Εφαρμογής
```bash
# Για Android device ή emulator
flutter run
```

### Πρώτη Χρήση / First Time Use

1. **Επιτρέψτε την πρόσβαση στην τοποθεσία (GPS)** όταν σας ζητηθεί
2. Η εφαρμογή είναι έτοιμη προς χρήση άμεσα

---

## 🔧 Τεχνικές Απαιτήσεις / Technical Requirements

### Android SDK Requirements

- **Minimum SDK Version**: **API Level 21** (Android 5.0 Lollipop)
- **Target SDK Version**: **API Level 34** (Android 14)