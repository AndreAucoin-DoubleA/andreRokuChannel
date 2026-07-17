sub init()
    m.pageBackground = m.top.findNode("pageBackground")
    m.bgAnim = m.top.findNode("bgAnim")
    m.bgWidthInterp = m.top.findNode("bgWidthInterp")
    m.top.translation = [0, 100]

    m.global.observeField("navCollapsed", "onNavCollapsedChanged")

    ' set the initial width directly, no animation
    m.pageBackground.width = page_width(m.global.navCollapsed)
end sub

function page_width(navCollapsed as boolean) as float
    if navCollapsed then return 1680.0
    return 1480.0
end function

sub onNavCollapsedChanged()
    m.bgWidthInterp.keyValue = [m.pageBackground.width, page_width(m.global.navCollapsed)]
    m.bgAnim.control = "stop"
    m.bgAnim.control = "start"
end sub
