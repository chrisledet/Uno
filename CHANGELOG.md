### v.0.1

* Features:
  * sync local folder _~/Ubuntu One_ with the Ubuntu One manually ("Sync Now" menu item).
   * display amount of available/used space.

* Bugfixes:
  * syncing does not block the main thread.
  * syncing does not try to download/upload all files at once. Downloads/Uploads are queued in a [NSOperationQueue](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/NSOperationQueue_class/Reference/Reference.html).