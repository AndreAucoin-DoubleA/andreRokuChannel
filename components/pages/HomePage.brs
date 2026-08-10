sub init()
    m.titleLabel = m.top.findNode("titleLabel")
    m.bodyLabel = m.top.findNode("bodyLabel")

    applyTheme()
end sub

sub applyTheme()
    t = Theme()

    m.titleLabel.color = t.color("component.page.titleColor", "0xFFFFFFFF")
    m.titleLabel.font = t.font("component.page.titleTypography", "font:LargeBoldSystemFont")

    m.bodyLabel.color = t.color("component.page.bodyColor", "0xAAAACCFF")
    m.bodyLabel.font = t.font("component.page.bodyTypography", "font:MediumSystemFont")
end sub
