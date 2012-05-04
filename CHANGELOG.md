### v0.2

  * Features
    * App now runs as an agent.
    * Added option to make status menu icon black & white or colored.    
    * Preference window no longer annoyingly resizes.
    * Show largest file size unit in the *Storage* section under *Account*.

### v0.1

* Features:
  * Sync local folder `~/Ubuntu One` with the Ubuntu One manually ("Sync Now" menu item).
   * Display amount of available/used space.

* Bugfixes:
  * Syncing does not block the main thread.
  * Syncing does not try to download/upload all files at once. Downloads/Uploads are queued in a [NSOperationQueue](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/NSOperationQueue_class/Reference/Reference.html).
  