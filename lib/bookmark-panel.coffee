$ = require 'jquery'
_ = require 'underscore'
cson = require 'cson'

BookmarkPanelView = require './bookmark-panel-view'
{CompositeDisposable} = require 'atom'

module.exports = BookmarkPanel =
	bookmarkPanelView: null
	modalPanel: null
	subscriptions: null

	activate: (state) ->
		# @bookmarkPanelView = new BookmarkPanelView(state.bookmarkPanelViewState)
		# @modalPanel = atom.workspace.addModalPanel(item: @bookmarkPanelView.getElement(), visible: false)

		# Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
		@subscriptions = new CompositeDisposable

		# Register command that toggles this view
		# @subscriptions.add atom.commands.add 'atom-workspace', 'bookmark-panel:toggle': => @toggle()

		@confFile = atom.project.getPaths()[0] + path.sep + 'bookmark-config.coffee'

		@panel = atom.workspace.addRightPanel(
			item: document.createElement('div')
			visible: true
			priority: 300
		)
		@contentDiv = document.createElement('div')
		@panel.item.appendChild @contentDiv

		atom.workspace.onDidChangeActivePaneItem (editor)=>
			if editor.onDidSave
				editor.onDidSave (event)=>
					@refreshPanel(editor)
			@refreshPanel(editor)

	# TODO: this needs to be fixed pronto, or else this will be a problem
	# However maybe not
	refreshPanel: (editor)->
		config = cson.parseCSFile(@confFile)
		@bookmarks = config.bookmarks
		@cleanPanel()
		if not editor.getLineCount
			return
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

					if !b.group
						@contentDiv.appendChild lineDiv
					else
						gr = _.find groups, (g)-> g.group is b.group
						gr.elements.push lineDiv

		for gr in groups
			groupLabel = document.createElement('div')
			groupLabel.classList.add('bookmark-group-label')
			groupLabel.textContent = gr.group
			@contentDiv.appendChild groupLabel
			for e in gr.elements
				@contentDiv.appendChild e

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

	# toggle: ->
	# 	console.log 'BookmarkPanel was toggled!'

	# 	if @modalPanel.isVisible()
	# 		@modalPanel.hide()
	# 	else
	# 		@modalPanel.show()
