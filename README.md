The new [Twitter for Mac 3.0](https://itunes.apple.com/us/app/twitter/id409789998?mt=12) is decent and is actually much better than the free alternatives.

One huge problem though: It still shows a star on the dock icon badge when there's new tweets.

![Star](http://i.imgur.com/gfYsknt.png)

Since the Twitter team probably doesn't consider this as an issue (It's been there since the Tweetie -> Twitter conversion, IIRC), I took matters into my own hands.

**PreciseTwitter** is a SIMBL plugin that fixes that issue:

![7](http://i.imgur.com/d4HG0BR.png)

Additionally, while testing PreciseTwitter I noticed that Twitter for Mac's window doesn't behave correctly on multi-monitor setups: It didn't seem to remember on which screen it was open when I reopened it. I added a fix for that, too.

---

If you're interested in only one of those fixes, you can disable the other this way:

`defaults write com.twitter.twitter-mac preciseTwitterDisableBadgeCount -bool TRUE`

or 

`defaults write com.twitter.twitter-mac preciseTwitterDisableMultiMonitorFix -bool TRUE`

### How to Install

1. Download and install [EasySIMBL](https://github.com/norio-nomura/EasySIMBL/#how-to-install) (recommended) or [SIMBL](http://www.culater.net/software/SIMBL/SIMBL.php)
2. Download PreciseTwitter here: [PreciseTwitter-1.0.zip](https://github.com/inket/PreciseTwitter/releases/download/v1.0/PreciseTwitter-1.0.zip)
3. Install cosyTabs:
	- **EasySIMBL**: Open EasySIMBL and drag & drop *PreciseTwitter.bundle* into the list.
	- **SIMBL**: Copy *PreciseTwitter.bundle* to `/Library/Application Support/SIMBL/Plugins/`.


### License
This program is licensed under GNU GPL v3.0 (see LICENSE)