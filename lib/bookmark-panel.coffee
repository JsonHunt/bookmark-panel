$ = require 'jquery'
_ = require 'underscore'
cson = require 'cson'
fs = require 'fs'

{CompositeDisposable} = require 'atom'

module.exports = BookmarkPanel =
	bookmarkPanelView: null
	modalPanel: null
	subscriptions: null

	activate: (state) ->
		@enabled = true
		@subscriptions = new CompositeDisposable
		@subscriptions.add atom.commands.add 'atom-workspace', 'bookmark-panel:toggle': => @toggle()

		@packageConfFile = atom.packages.resolvePackagePath('bookmark-panel') + path.sep + 'bookmark-config.coffee'
		fs.readFile @packageConfFile, (err,data)=>
			if data
				config = cson.parseCSString(data.toString())
				@defBookmarks = config.bookmarks

		@globalConfFile = "#{atom.project.getPaths()[0]}#{path.sep}..#{path.sep}bookmark-config.coffee"
		@confFile = atom.project.getPaths()[0] + path.sep + 'bookmark-config.coffee'

		@panel = atom.workspace.addRightPanel(
			item: document.createElement('div')
			visible: true
			priority: 300
		)
		@contentDiv = document.createElement('div')
		@panel.item.classList.add('bookmark-panel')
		@panel.item.appendChild @contentDiv


		atom.workspace.observeActivePaneItem (editor)=>
			if editor and editor.onDidSave and !editor.bookmarkSaveHandle
				editor.bookmarkSaveHandle = editor.onDidSave (event)=>
					@refreshPanel()
			@refreshPanel()

	refreshPanel: ()->
		editor = atom.workspace.getActiveTextEditor()
		@cleanPanel()
		if !editor or (not @enabled) or (not editor.getLineCount)
			@panel.hide()
			return

		fs.readFile @globalConfFile, (err,data)=>
			if data
				gconfig = cson.parseCSString(data.toString())
				@bookmarks = gconfig.bookmarks
			else
				@bookmarks = []

			fs.readFile @confFile, (err,data)=>
				if data
					lconfig = cson.parseCSString(data.toString())
					@bookmarks = @bookmarks.concat(lconfig.bookmarks)
				@bookmarks = @bookmarks.concat @defBookmarks

				console.log "Default bookmarks: #{@defBookmarks.length}"
				console.log "Global bookmarks: #{gconfig.bookmarks.length}" if gconfig
				console.log "Project bookmarks: #{lconfig.bookmarks.length}" if lconfig

				matchingBookmarks = []
				groups = []
				for b in @bookmarks
					b.filename = new RegExp(b.filename) if b.filename
					if !b.filename or editor.getTitle().match(b.filename)
						matchingBookmarks.push b
						if b.group
							groups.push {
								group: b.group
								elements: []
							}
				showPanel = false
				for i in [0..editor.getLineCount()]
					text = editor.lineTextForBufferRow(i)
					for b in matchingBookmarks
						m = b.regexp.exec(text)
						if m
							if b.labelfx
								label = b.labelfx(m)
							else
								label = m[0]
							lineDiv = document.createElement('div')
							lineDiv.textContent = label
							lineDiv.classList.add('bookmark-item')
							lineDiv.bufferLineIndex = i
							$(lineDiv).click (event)->
								editor.setCursorBufferPosition [event.target.bufferLineIndex]
								editor.moveToEndOfLine()

							if !b.group
								@contentDiv.appendChild lineDiv
								showPanel = true
							else
								gr = _.find groups, (g)-> g.group is b.group
								gr.elements.push lineDiv

				for gr in groups
					continue if gr.elements.length is 0
					groupLabel = document.createElement('div')
					groupLabel.classList.add('bookmark-group-label')
					groupLabel.textContent = gr.group
					@contentDiv.appendChild groupLabel
					for e in gr.elements
						@contentDiv.appendChild e
						showPanel = true

				if showPanel
					@panel.show()
				else
					@panel.hide()

	cleanPanel: ->
		@contentDiv.remove()
		@contentDiv = document.createElement('div')
		@panel.item.appendChild @contentDiv

	deactivate: ->
		# @modalPanel.destroy()
		@subscriptions.dispose()
		# @bookmarkPanelView.destroy()

	serialize: ->
		# bookmarkPanelViewState: @bookmarkPanelView.serialize()

	toggle: ->
		@enabled = not @enabled
		@refreshPanel()
