sub init()
    m.favIcon = m.top.findNode("favIcon")

    ' Scale about the icon's centre, not its top-left corner, so focus grows
    ' it in place instead of pushing it down and right.
    m.top.scaleRotateCenter = [32, 32]

    m.top.observeField("focusedChild", "onFocusChanged")

    ' Fields left at their default value never fire onChange, so paint once.
    onFavoritedChanged()
    onFocusChanged()
end sub

sub onFavoritedChanged()
    ' An external write to favorited can land before init() has run.
    if m.favIcon = invalid then return

    if m.top.favorited
        m.favIcon.uri = "pkg:/images/favorite_filled.png"
    else
        m.favIcon.uri = "pkg:/images/favorite_empty.png"
    end if
end sub

sub onFocusChanged()
    if m.top.hasFocus()
        m.favIcon.opacity = 1.0
        m.top.scale = [1.15, 1.15]
    else
        m.favIcon.opacity = 0.6
        m.top.scale = [1.0, 1.0]
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press and key = "OK"
        m.top.favorited = not m.top.favorited
        return true
    end if

    ' up/down are the parent's business - let them bubble.
    return false
end function
