CSSU - Cisco 700 series router setup utility verion 0.1.0 08.04.2001
====================================================================

1.) Legal stuff

This is freeware under the GNU General Public License. Use at your risk.
See enclosed file COPYING for details.

2.) What is this?

This is a little utility that overcomes a big annoyance of my Cisco 760
router: It does not remember time and date (Hey, every ISDN call provides
time and date, so this really should not be an issue, but...).

Well, you can set this program up to set time and date of the router 
according to your PC system time/date and leave 5 seconds afterwards.

That's the main purpose it was written for. However, a few thing got added
that I considered useful.

The GUI should be quite self explanatory, take a look at the hints line
on the bottom of the window.

- You can store the router's configuration in a file on your disk.
- You can upload a configuration file from disk to your router.
- You can kill all current ISDN connections immediately.
- You can reboot the router (and set time/date afterwards automatically).
- You can reset the router to factory defaults.

3.) Installation

    1. Copy CSSU.EXE into a diretory of your choice.
    2. Make a program object on your desktop pointing to CSSU.EXE.
    3. Copy the enclosed RXASYNC.DLL and RXEXTRAS.DLL into your LIBPATH.
       (You have to get RxExtras from hobbes, RXX1G.ZIP is the file.)
    4. Be sure to have VROBJ.DLL (VX-REXX runtime) in your LIBPATH
       (If yo don't have it, it is located on your Warp 4 CD-ROM and it 
       should also be somewhere on the eCS CD-ROM)
    4. You are done. Use it!
    
4.) Author

    My name is Herwig Bauernfeind. I am the guy who started RexxAutoStart
    and the German translation of the Lxlite docs a few years ago.
    
    If you have bug reports, feature requests, just tell me so, any
    feedback is appreciated.
    
    Email:   herwig.bauernfeind@aon.at
    Fidonet: Herwig Bauernfeind@2:313/41.5
