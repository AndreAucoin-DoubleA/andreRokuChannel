sub init()
    m.menuList = m.top.findNode("menuList")

    content = CreateObject("roSGNode", "ContentNode")
    for each page in PageRegistry()
        if page.type = "nav" then addItem(content, page.label, page.icon)
    end for
    m.menuList.content = content

    m.menuList.observeField("itemFocused", "onFocusChanged")
end sub

sub addItem(parent as object, label as string, iconUri as string)
    item = parent.createChild("ContentNode")
    item.title = label
    item.hdPosterUrl = iconUri
end sub

sub onFocusChanged()
    m.top.itemFocused = m.menuList.itemFocused
end sub

sub onCollapsedChanged()
    m.global.navCollapsed = m.top.collapsed
end sub

sub setFocusToList()
    m.menuList.setFocus(true)
end sub
