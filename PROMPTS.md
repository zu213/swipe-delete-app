# Prompts Log

This file tracks all prompts given to Claude for this project.

## Session: 2026-03-29

1. **Make a readme file PROMPTS.md**
   - Create a PROMPTS.md file to track all prompts typed
   - Add reminder in claude.md for future runs to maintain this file

2. **Create Tinder-style photo management app**
   - Single page app with photo access permission
   - Swipe left to delete photos
   - Swipe right to keep photos
   - For quick photo management and cleanup

3. **Where does Info.plist live / how to add it**
   - Need to locate or create Info.plist for photo permissions

4. **Fix "Multiple commands produce Info.plist" error**
   - Getting build error about duplicate Info.plist generation

5. **Fix PhotoManager initialization error**
   - Error: 'self' used in method call 'checkAuthorization' before all stored properties are initialized

6. **Fix ambiguous font error in SwipeablePhotoCard**
   - Error: Ambiguous use of 'font' in isDragging overlay section

7. **Lower iOS deployment target to iOS 18.5**
   - Need to update minimum iOS version to install on iOS 18.5

8. **Fix provisioning profile requirement**
   - Error: "swipe-photo-delete" requires a provisioning profile

9. **App crashes when granting photo access**
   - Error: App crashes because NSPhotoLibraryUsageDescription key is missing from Info.plist

10. **Remove delete confirmation popup**
   - Popup appears every time a photo is deleted, need to prevent this

11. **Photo display not updating after swipe**
   - Same photo shows after each swipe decision, but different photos are being deleted

12. **Batch deletions to reduce popups**
   - System popup still appears on each delete, implement batch deletion every 10 photos to reduce popup frequency

13. **Photos skipping when delete prompt appears**
   - When the delete confirmation prompt appears, photos get skipped regardless of confirm/cancel choice

## Session: 2026-04-08

14. **Standardize code formatting and add documentation**
   - Convert all Swift files from 4-space to 2-space indentation
   - Create README.md with project overview, features, and structure
