sub init()
    m.icon = m.top.findNode("icon")
    m.label = m.top.findNode("label")
    m.highlight = m.top.findNode("highlight")
    m.collapseAnim = m.top.findNode("collapseAnim")
    m.fadeInterp = m.top.findNode("fadeInterp")
    m.highlightWidthInterp = m.top.findNode("highlightWidthInterp")

    applyTheme()

    ' Re-theme in place if the token table is ever swapped at runtime.
    ' This is the whole reason applyTheme() is a separate sub.
    m.global.observeField("designTokens", "applyTheme")
    m.global.observeField("navCollapsed", "onCollapsedChanged")

    collapsed = m.global.navCollapsed
    m.label.opacity = labelOpacity(collapsed)
    m.highlight.width = highlightWidth(collapsed)
end sub

' Every themed assignment lives here and nowhere else.
' Only component.* tokens are referenced - never a primitive like
' color.brand.primary - so a rebrand never touches this file.
sub applyTheme()
    t = Theme(true)

    ' Cached on m because updateHighlight() runs on every focus frame; it must
    ' stay a pure field assignment with no token lookups in that hot path.
    m.labelColor = t.color("component.navItem.labelColor", "0x888899FF")
    m.labelColorFocused = t.color("component.navItem.labelColorFocused", "0xFFFFFFFF")

    m.widthExpanded = t.size("component.navItem.width", 250)
    m.widthCollapsed = t.size("component.navItem.widthCollapsed", 80)

    itemHeight = t.size("component.navItem.height", 70)

    m.highlight.blendColor = t.color("component.navItem.highlightColor", "0x6C3FA0FF")
    m.highlight.height = itemHeight

    m.label.height = itemHeight
    m.label.color = m.labelColor
    m.label.font = t.font("component.navItem.labelTypography", "font:MediumSystemFont")
end sub

function labelOpacity(collapsed as boolean) as float
    if collapsed then return 0.0
    return 1.0
end function

function highlightWidth(collapsed as boolean) as float
    if collapsed then return m.widthCollapsed
    return m.widthExpanded
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
        m.label.color = m.labelColorFocused
    else
        m.label.color = m.labelColor
    end if
end sub

sub onCollapsedChanged()
    collapsed = m.global.navCollapsed
    m.fadeInterp.keyValue = [m.label.opacity, labelOpacity(collapsed)]
    m.highlightWidthInterp.keyValue = [m.highlight.width, highlightWidth(collapsed)]
    m.collapseAnim.control = "stop"
    m.collapseAnim.control = "start"
end sub
