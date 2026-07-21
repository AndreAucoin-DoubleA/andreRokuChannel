sub init()
    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")
end sub

sub onContentChanged()
    content = m.top.itemContent
    if content <> invalid
        m.poster.uri = content.HDPosterUrl
        m.title.text = content.title
    end if
end sub
