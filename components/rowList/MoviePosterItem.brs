sub init()
    m.poster = m.top.findNode("poster")
    m.focusAnim = m.top.findNode("focusAnim")
    m.scaleInterp = m.top.findNode("scaleInterp")
    m.transInterp = m.top.findNode("transInterp")
    m.focused = false

    m.global.observeField("navCollapsed", "onNavStateChanged")
end sub

function isFocused() as boolean
    return m.top.focusPercent >= 0.5 and m.top.rowFocusPercent >= 0.5 and m.global.navCollapsed
end function

sub onNavStateChanged()
    updateFocus()
end sub

sub onContentChanged()
    content = m.top.itemContent
    if content <> invalid
        m.poster.uri = content.HDPosterUrl
    end if

    m.focused = false
    m.focusAnim.control = "stop"
    snapTo(false)
end sub

sub onFocusPercentChanged()
    updateFocus()
end sub

sub updateFocus()
    shouldFocus = isFocused()
    if shouldFocus = m.focused then return
    m.focused = shouldFocus

    m.focusAnim.control = "stop"
    m.scaleInterp.keyValue = [m.poster.scale, targetScale(shouldFocus)]
    m.transInterp.keyValue = [m.poster.translation, targetTrans(shouldFocus)]
    m.focusAnim.control = "start"
end sub

sub snapTo(focused as boolean)
    m.poster.scale = targetScale(focused)
    m.poster.translation = targetTrans(focused)
end sub

function targetScale(focused as boolean) as object
    if focused then return [1.15, 1.15]
    return [1.0, 1.0]
end function

function targetTrans(focused as boolean) as object
    if focused then return [15, 12]
    return [15, 32]
end function
