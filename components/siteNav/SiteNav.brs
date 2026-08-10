sub init()
    m.menuList = m.top.findNode("menuList")
    applyTheme()
    m.global.observeField("designTokens", "applyTheme")

    content = CreateObject("roSGNode", "ContentNode")
    for each page in PageRegistry()
        if page.type = "nav"
            item = content.createChild("ContentNode")
            item.setFields({ title: page.label, hdPosterUrl: page.icon })
        end if
    end for
    m.menuList.content = content
end sub

sub applyTheme()
    t = Theme(true)
    itemWidth = t.size("component.navItem.width", 250)
    itemHeight = t.size("component.navItem.height", 70)
    m.menuList.itemSize = [itemWidth, itemHeight]
end sub

sub setFocusToList()
    m.menuList.setFocus(true)
end sub
