:warning: **Announcement: This library is no longer being actively developed.**  

# BTMoviePlayerController
Brightec BTMoviePlayerController based on AVPlayer. Supports volume level adjustments.

This project was built for a specfic project in mind so it does not support any customimsation without changing the source code directly.

**Projct Goals:**
- Implement a custom movie player controller based on AVPlayer.
- Implement a fully custom player UI with scrubber bar, buffer info, play, pause, stop, slowmo, volume and mute controls.
- Implement a volume slider that is not dependent on MPVolumeView.
- Implement a slow motion feature.


At this time all of the above features have been implemented. 

**Limitations:**

Volume slider feature only controls the volume level from 0-100% of the total current system volume. I.e. if the system volume is 50% and the app volume slider is 50% then the volume output will be 25%. This limitation was unknown at time of development. I've left this in as a proof of concept but it would not be hard to adapt to using the MPVolumeView.

**Usage:**

Just open the project and hit run. To make changes just fork the repository and then make the necessary changes and either copy the source files into your project or add as a sub-project.

To test local video playback download http://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_640x360.m4v and move it to the BTMoviePlayerController/ directory.
