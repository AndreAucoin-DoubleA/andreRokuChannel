sub init()
    m.rowList = m.top.findNode("rowList")
    m.loadingLabel = m.top.findNode("loadingLabel")
    m.loaded = false
    m.top.observeField("visible", "onVisibleChanged")
    m.rowList.observeField("rowItemSelected", "onMovieSelected")

    m.rootContent = CreateObject("roSGNode", "ContentNode")
    m.rowList.content = m.rootContent
end sub

sub onMovieSelected()
    sel = m.rowList.rowItemSelected
    if sel = invalid or m.rowList.content = invalid then return

    row = m.rowList.content.getChild(sel[0])
    if row = invalid then return

    m.top.selectedMovie = row.getChild(sel[1])
end sub

sub onRowBatchReady(msg as object)
    batch = msg.GetData()
    if batch = invalid then return
    kids = batch.GetChildren(-1, 0)
    if kids.Count() = 0 then return
    batch.RemoveChildren(kids)
    m.rootContent.AppendChildren(kids)
    m.loadingLabel.visible = false
end sub

sub onVisibleChanged()
    if m.top.visible and not m.loaded
        m.loaded = true
        m.loadingLabel.visible = true
        m.movieTask = CreateObject("roSGNode", "PopulateMoviesTask")
        m.movieTask.batchSize = 5
        m.movieTask.observeField("rowBatch", "onRowBatchReady")
        m.movieTask.observeField("loadComplete", "onLoadComplete")
        m.movieTask.control = "RUN"
    end if
end sub

function focusContent() as boolean
    return m.rowList.setFocus(true)
end function

sub onLoadComplete()
    if m.rootContent.GetChildCount() = 0
        m.loadingLabel.text = "Couldn't load movies"
        m.loadingLabel.visible = true
    end if
end sub


