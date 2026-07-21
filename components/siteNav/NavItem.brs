sub init()
    m.icon = m.top.findNode("icon")
    m.label = m.top.findNode("label")
    m.highlight = m.top.findNode("highlight")
    m.collapseAnim = m.top.findNode("collapseAnim")
    m.fadeInterp = m.top.findNode("fadeInterp")
    m.highlightWidthInterp = m.top.findNode("highlightWidthInterp")

    m.global.observeField("navCollapsed", "onCollapsedChanged")

    ' set the initial state directly, no animation
    collapsed = m.global.navCollapsed
    m.label.opacity = bool_to_opacity(not collapsed)
    m.highlight.width = nav_width(collapsed)
end sub

function bool_to_opacity(visible as boolean) as float
    if visible then return 1.0
    return 0.0
end function

function nav_width(collapsed as boolean) as float
    if collapsed then return 80.0
    return 300.0
end function

sub onContentChanged()
    content = m.top.itemContent
    m.label.text = content.title
    m.icon.uri = content.hdPosterUrl
end sub

sub updateHighlight()
    p = m.top.focusPercent
    opacity = p
    if not m.top.listHasFocus
        opacity = opacity * 0.45
    end if
    m.highlight.opacity = opacity

    r = lerp(&h88, &hFF, p)
    g = lerp(&h88, &hFF, p)
    b = lerp(&h99, &hFF, p)
    m.label.color = (r << 24) + (g << 16) + (b << 8) + &hFF
end sub

function lerp(low as integer, high as integer, percent as float) as integer
    return low + int((high - low) * percent)
end function

sub onCollapsedChanged()
    collapsed = m.global.navCollapsed
    m.fadeInterp.keyValue = [m.label.opacity, bool_to_opacity(not collapsed)]
    m.highlightWidthInterp.keyValue = [m.highlight.width, nav_width(collapsed)]
    m.collapseAnim.control = "stop"
    m.collapseAnim.control = "start"
end sub
