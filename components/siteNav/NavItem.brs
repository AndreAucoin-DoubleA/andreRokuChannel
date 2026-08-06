sub init()
    m.icon = m.top.findNode("icon")
    m.label = m.top.findNode("label")
    m.highlight = m.top.findNode("highlight")
    m.collapseAnim = m.top.findNode("collapseAnim")
    m.fadeInterp = m.top.findNode("fadeInterp")
    m.highlightWidthInterp = m.top.findNode("highlightWidthInterp")

    m.global.observeField("navCollapsed", "onCollapsedChanged")

    collapsed = m.global.navCollapsed
    m.label.opacity = labelOpacity(collapsed)
    m.highlight.width = highlightWidth(collapsed)
end sub

function labelOpacity(collapsed as boolean) as float
    if collapsed then return 0.0
    return 1.0
end function

function highlightWidth(collapsed as boolean) as float
    if collapsed then return 80.0
    return 250.0
end function

sub onContentChanged()
    content = m.top.itemContent
    m.label.text = content.title
    m.icon.uri = content.hdPosterUrl
end sub

sub updateHighlight()
    p = m.top.focusPercent

    dimFactor = 1.0
    if not m.top.listHasFocus then dimFactor = 0.45
    m.highlight.opacity = p * dimFactor

    if p > 0.5
        m.label.color = &hFFFFFFFF
    else
        m.label.color = &h888899FF
    end if
end sub

sub onCollapsedChanged()
    collapsed = m.global.navCollapsed
    m.fadeInterp.keyValue = [m.label.opacity, labelOpacity(collapsed)]
    m.highlightWidthInterp.keyValue = [m.highlight.width, highlightWidth(collapsed)]
    m.collapseAnim.control = "stop"
    m.collapseAnim.control = "start"
end sub
