sub init()
    m.poster = m.top.findNode("poster")
    m.focusRing = m.top.findNode("focusRing")
end sub

' The ring belongs to the current item of the row that actually has focus.
function isRowFocused() as boolean
    return m.top.focusPercent >= 0.5 and m.top.rowFocusPercent >= 0.5
end function

sub onContentChanged()
    content = m.top.itemContent
    if content = invalid
        m.poster.uri = ""
    else
        m.poster.uri = content.HDPosterUrl
    end if

    m.focusRing.visible = isRowFocused()
end sub

sub onFocusChanged()
    m.focusRing.visible = isRowFocused()
end sub
