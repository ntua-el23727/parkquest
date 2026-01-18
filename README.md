# ParkQuest

## Overview

**ParkQuest** is a smart parking management application that helps users save, remember, and navigate back to their parked car location. The app integrates with Google Maps to provide navigation, allows users to add notes and photos to their parking spots, and has a community that shares parking spots in the app. Users can earn points through parking activities and unlock rewards like free coffee, gift cards, and parking vouchers.

## Features / Χαρακτηριστικά

### Core Features
- **Main Application Page**: Home screen with shared parking spots carousel
  
  <div align="center">
    <img src="assets/images/App%20Screenshots/Main%20Application%20page.png" width="150">
  </div>

- **Save Parking Location**: Instantly save your current location with GPS coordinates
  
  <div align="center">
    <img src="assets/images/App%20Screenshots/Location%20Saved.png" width="150">
  </div>

- **Find My Car**: Get navigation back to your parked vehicle using Google Maps Routes API
  
  <div align="center">
    <img src="assets/images/App%20Screenshots/Directions.png" width="150">
  </div>

- **Parking Notes**: Add custom notes about your parking spot

- **Shared Parking Spots**: Discover available parking spots shared by other users nearby
  
  <div align="center">
    <img src="assets/images/App%20Screenshots/Profile%20Shared%20Spots.png" width="150">
  </div>

- **Rewards System**: Earn points for parking activities and unlock rewards

- **Activity History**: Track all your parking events with detailed history
  
  <div align="center">
    <img src="assets/images/App%20Screenshots/Profile%20History.png" width="150">
  </div>

---

## Οδηγίες Εγκατάστασης / Installation Instructions

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
```

#### 2. Google Maps API Key

Η εφαρμογή χρειάζεται Google Maps API Key για να λειτουργήσει. [Google Cloud Console](https://console.cloud.google.com/)

#### 3. Ρύθμιση API Keys

Προσθέστε το API key στα παρακάτω αρχεία:
   - `.env`: `GOOGLE_MAPS_API_KEY=YOUR_KEY`
   - `android/local.properties`: `GOOGLE_MAPS_API_KEY=YOUR_KEY`

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

## Εύκολη εγκατάσταση / Easy Installation

### APK Download
Κατεβάστε και εγκαταστήστε το APK απευθείας στη συσκευή σας Android:
- [Download ParkQuest APK](assets/application/parkquest.apk)

### Βίντεο Επίδειξης / App Demo Recording
Δείτε ένα demo της εφαρμογής ParkQuest:
- [View Demo Video](assets/application/parkquest_demo_recording.mp4)


## 🔧 Τεχνικές Απαιτήσεις / Technical Requirements

### Android SDK Requirements

- **Minimum SDK Version**: **API Level 21** (Android 5.0 Lollipop)
- **Target SDK Version**: **API Level 34** (Android 14)
