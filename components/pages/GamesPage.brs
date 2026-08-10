sub init()
    m.titleLabel = m.top.findNode("titleLabel")
    m.gamesList = m.top.findNode("gamesList")

    applyTheme()
end sub

sub applyTheme()
    t = Theme()

    m.titleLabel.color = t.color("component.page.titleColor", "0xFFFFFFFF")
    m.titleLabel.font = t.font("component.page.titleTypography", "font:LargeBoldSystemFont")

    bodyColor = t.color("component.page.bodyColor", "0xAAAACCFF")
    bodyFont = t.font("component.page.bodyTypography", "font:MediumSystemFont")

    for i = 0 to m.gamesList.getChildCount() - 1
        row = m.gamesList.getChild(i)
        row.color = bodyColor
        row.font = bodyFont
    end for
end sub
