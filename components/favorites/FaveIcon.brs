sub init()
    m.favIcon = m.top.findNode("favIcon")

    m.top.scaleRotateCenter = [32, 32]

    m.top.observeField("focusedChild", "onFocusChanged")

    onFavoritedChanged()
    onFocusChanged()
end sub

sub onFavoritedChanged()
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

    return false
end function
