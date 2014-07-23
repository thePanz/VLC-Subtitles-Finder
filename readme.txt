Usage:
 - Open a movie in VLC
 - (optional) Stop the movie
 - Open the the VLC menu: "View->Subtitles Finder" (this activates the plugin)
 - Open the the plugin menu: "View->Subtitles Finder->Download"

Installation:
 - Place SubtitlesFinder.lua in your vlc extensions directory
   - Linux (all users): /usr/share/vlc/lua/extensions/
   - Linux (current user): ~/.local/share/vlc/lua/extensions/
   - Windows (all users): %ProgramFiles%\VideoLAN\VLC\lua\extensions\
   - Windows (current user): %APPDATA%\VLC\lua\extensions\
   - Mac OS X (all users): /Applications/VLC.app/Contents/MacOS/share/lua/extensions/

Notes:
  - Because of internal changes in VLC, the minimum version of VLC required is 1.1.0
  - VLC support only uncompressed .rar files
  - VLC 1.1.x do not support lua scripts that uses GUIs under MAC-OSx, so:
    this plugin WILL NOT work on your MAC!

Know issues:
  - The search fail if you click the button two times consecutively

Recent fixes:
  - Now works on Linux-VLC. The fix should not break Windows VLC, but is untested. [by Abraham van Helpsing]
  
Thanks to:
  - Mederi (Various fixes and corrections)
  - Ciprus (Testing)
  - Abraham van Helpsing (Linux fixes)
