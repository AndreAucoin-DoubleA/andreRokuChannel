sub init()
    m.rowList = m.top.findNode("rowList")
    m.movieTask = CreateObject("roSGNode", "PopulateMoviesTask")
    m.movieTask.observeField("content", "onMoviesLoaded")
    m.movieTask.control = "RUN"
end sub

function focusContent() as boolean
    return m.rowList.setFocus(true)
end function

sub onMoviesLoaded(msg as object)
    content = msg.GetData()
    print "DEBUG onMoviesLoaded content: "; content; " rowList: "; m.rowList
    if content <> invalid
        m.rowList.content = content
    end if
end sub
