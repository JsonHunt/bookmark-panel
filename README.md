# bookmark-panel package

Adds a side panel showing automatic anchors/bookmarks in active file.
There is a set of standard bookmarks included in the package.
To add your own, create bookmarks-config.coffee in your project root,
or your projects folder.

Configure your bookmarks like this:

```
bookmarks: [
	{
		filename: '.coffee'
		regexp: ///\s*class\s(.*)///
		labelfx: (match)->
			return "Class #{match[1]}"
	},{
		filename: '.coffee'
		regexp: ///\s*(.*?):\s*(\(.*?\))?\s*->///
		labelfx: (match)->
			return "#{match[1]}"
	},{
		group: "TO-DO"
		regexp: ///TO-?DO: (.*)///
		labelfx: (match)->
			return "#{match[1]}"
	}
]

```
The panel will now appear if active file contains one or more matching bookmarks.
Clicking on a bookmark will take you to it.
You can group your bookmarks, define which files they apply to (optional,using regex),
define regex patterns and label functions (optional)

Currently, generic TO-DOs and CoffeeScript classes + class methods are included.
If you add other useful bookmark types, you are welcome to contribute.
