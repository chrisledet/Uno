about
--------
[Ubuntu One](http://one.ubuntu.com/) Cleint for the Mac OS.

changelog
--------
v.0.1:
features:
- sync local folder _~/Ubuntu One_ with the Ubuntu One manually ("Sync Now" menu item).
- display amount of available/used space.

bugfixes:
- syncing does not block the main thread.
- syncing does not try to download all files at once. Downloads are queued in a [NSOperationQueue](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/NSOperationQueue_class/Reference/Reference.html).
