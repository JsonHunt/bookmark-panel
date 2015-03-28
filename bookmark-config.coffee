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
			return ": #{match[1]}"
	},{
		group: "TODO"
		regexp: ///TO-?DO: (.*)///
		labelfx: (match)->
			return "#{match[1]}"
	}
]
