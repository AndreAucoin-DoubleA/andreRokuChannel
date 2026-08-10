sub init()
    m.poster = m.top.findNode("poster")
    m.focusRing = m.top.findNode("focusRing")
    m.posterMask = m.top.findNode("posterMask")

    applyTheme()
    m.global.observeField("designTokens", "applyTheme")
end sub

sub applyTheme()
    t = Theme(true)

    m.focusRing.width = t.size("component.moviePoster.width", 376)
    m.focusRing.height = t.size("component.moviePoster.height", 220)

    imageWidth = t.size("component.moviePoster.imageWidth", 356)
    imageHeight = t.size("component.moviePoster.imageHeight", 200)

    m.posterMask.maskSize = [imageWidth, imageHeight]
    m.poster.width = imageWidth
    m.poster.height = imageHeight

    m.poster.loadWidth = imageWidth
    m.poster.loadHeight = imageHeight
end sub

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
