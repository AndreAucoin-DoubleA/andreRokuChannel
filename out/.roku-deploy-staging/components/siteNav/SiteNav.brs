sub init()
    m.menuList = m.top.findNode("menuList")
    m.navBackground = m.top.findNode("navBackground")
    m.collapseAnim = m.top.findNode("collapseAnim")
    m.widthInterp = m.top.findNode("widthInterp")

    content = CreateObject("roSGNode", "ContentNode")
    addItem(content, "Home", "pkg:/images/home_icon.png")
    addItem(content, "Movies", "pkg:/images/settings_icon.png")
    addItem(content, "Games", "pkg:/images/menu_icon.png")
    m.menuList.content = content

    m.menuList.observeField("itemFocused", "onFocusChanged")
    m.menuList.observeField("itemSelected", "onItemSelected")
end sub

sub addItem(parent as object, label as string, iconUri as string)
    item = parent.createChild("ContentNode")
    item.title = label
    item.hdPosterUrl = iconUri
end sub

sub onFocusChanged()
    m.top.itemFocused = m.menuList.itemFocused
end sub

sub onItemSelected()
    m.top.itemSelected = m.menuList.itemSelected
end sub

sub onCollapsedChanged()
    if m.top.collapsed
        targetWidth = 100
    else
        targetWidth = 300
    end if

    m.widthInterp.keyValue = [m.navBackground.width, targetWidth]
    m.collapseAnim.control = "stop"
    m.collapseAnim.control = "start"
    m.global.navCollapsed = m.top.collapsed
end sub

sub setFocusToList()
    m.menuList.setFocus(true)
end sub
