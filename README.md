# MyJourney
This app allows you to create and view journal entries from anywhere using Firebase cloud storage. Entries can include text, images, date, time, and weather details. You can view your entries in a collapsible table format or as pins on a map. Simply click on a pin or table entry to revisit your past experiences.

# Features
- Local storage
- Web/API services
- Firebase account creation and authentication
- Maps and location services
- Gesture handling

This collapsible table format was probably the most technical part, taking up a lot of time and having quite a few bugs with "ghost" rows and wrong images being used when I first got it working. i have since fixed them and hopefully it runs bug free. It was done by having a table view inside another table view, which I now realise probably isn't the best options and I could just have a single table view.

<img src="https://github.com/user-attachments/assets/cd0350d0-4b35-4df0-b74b-ebaf5674948b" alt="Entries View" height="600"/>

I quite like this map view, displaying an uploaded image instead of a generic pin icon. You can easily identify and revist experiences from all across the world.

<img src="https://github.com/user-attachments/assets/55fafd31-3239-4ac9-90ab-b14c1e034ead" alt="Map View" height="600"/>

# Usage
Download the repo and run it in Xcode simulation or export to an Apple device.
