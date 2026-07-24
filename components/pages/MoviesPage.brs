sub init()
    m.rowList = m.top.findNode("rowList")
    m.loadingLabel = m.top.findNode("loadingLabel")
    m.loaded = false
    m.top.observeField("visible", "onVisibleChanged")
    m.rowList.observeField("rowItemSelected", "onMovieSelected")
end sub

sub onMovieSelected()
    sel = m.rowList.rowItemSelected
    if sel = invalid or m.rowList.content = invalid then return

    row = m.rowList.content.getChild(sel[0])
    if row = invalid then return

    m.top.selectedMovie = row.getChild(sel[1])
end sub

sub onVisibleChanged()
    if m.top.visible and not m.loaded
        m.loaded = true
        m.loadingLabel.visible = true
        m.movieTask = CreateObject("roSGNode", "PopulateMoviesTask")
        m.movieTask.observeField("content", "onMoviesLoaded")
        m.movieTask.control = "RUN"
    end if
end sub

function focusContent() as boolean
    return m.rowList.setFocus(true)
end function

sub onMoviesLoaded(msg as object)
    m.loadingLabel.visible = false
    content = msg.GetData()
    if content <> invalid
        m.rowList.content = content
    else
        m.loadingLabel.text = "Couldn't load movies."
        m.loadingLabel.visible = true
    end if
end sub
