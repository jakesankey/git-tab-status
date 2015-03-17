$ = require "jquery"
fs = require "fs"

class GitTabStatus
    activate: ->
        @_updateTabs()
        @_setupWatchConditions()

    deactivate: ->
        clearInterval @watcher
        $(".tab [data-path]").removeClass "status-added status-modified status-ignored"

    _setupWatchConditions: ->
        @watcher = setInterval @_updateTabs, 500

    _updateTabs: =>
        @_updateTabStylesForPath editor.getPath() for editor in @_getEditors()

    _getEditors: -> atom.workspace.getTextEditors()

    _getRepositories: -> atom.project.getRepositories()

    _updateTabStylesForPath: (path) =>
        if @_pathExists path
            [isModified, isNew, isIgnored] = []

            @_getRepositories().forEach (repo) ->
                isModified ||= repo?.isPathModified(path)
                isNew ||= repo?.isPathNew(path)
                isIgnored ||= repo?.isPathIgnored(path)

            tab = @_findTabForPath path
            if isModified
                tab?.addClass "status-modified"
            else if isNew
                tab?.addClass "status-added"
            else if isIgnored
                tab?.addClass "status-ignored"
            else
                tab?.removeClass "status-added status-modified status-ignored"

    _pathExists: (path) -> fs.existsSync path

    _findTabForPath: (path) ->
        path = path.replace /\\/g, '\\\\'
        $(".tab [data-path='#{path}']")

module.exports = new GitTabStatus()
