sub init()
    m.poster = m.top.findNode("poster")
    m.focusRing = m.top.findNode("focusRing")
end sub

function isFocused() as boolean
    return m.top.itemHasFocus and m.top.rowHasFocus
end function

sub onContentChanged()
    content = m.top.itemContent

    if content = invalid
        m.poster.uri = ""
    else
        m.poster.uri = content.HDPosterUrl
    end if

    m.focusRing.visible = isFocused()
end sub

sub onFocusChanged()
    m.focusRing.visible = isFocused()
end sub
