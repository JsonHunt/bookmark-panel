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
		filename: '.js'
		regexp: ///var (.*?)\s*=\s*function\s*\(.*?\)///
		labelfx: (match)->
			return "#{match[1]}"
	},{
		group: "TODO"
		regexp: ///TO-?DO: (.*)///i
		labelfx: (match)->
			return "#{match[1]}"
	}
]
