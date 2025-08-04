# Copilot Instructions for Daily Photo App

<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

This is a Flutter macOS application that automatically takes a photo when the user unlocks their computer for the first time each day. The app includes a gallery to display daily photos.

## Project Structure
- `lib/main.dart` - Main application entry point
- `lib/services/` - Core services (camera, storage, system events)
- `lib/screens/` - UI screens (gallery, settings)
- `lib/models/` - Data models
- `macos/` - macOS-specific configuration

## Key Features
1. **System Unlock Detection** - Monitor macOS system events to detect when user unlocks the computer
2. **Daily First-Time Logic** - Check if a photo has already been taken today
3. **Camera Integration** - Access system camera to take photos automatically
4. **Photo Storage** - Save photos with timestamps in organized folders
5. **Gallery Display** - Show daily photos in a grid/timeline view
6. **Background Operation** - Run silently in background, minimal UI intervention

## Technical Requirements
- macOS permissions for camera access
- System event monitoring capabilities
- Local file storage for photos
- Background app execution
- Date/time handling for daily logic

## Development Guidelines
- Use Flutter's platform channels for macOS-specific functionality
- Implement proper error handling for camera and file operations
- Follow Flutter best practices for state management
- Ensure app can run minimized/in background
- Handle edge cases like missing camera or storage permissions
