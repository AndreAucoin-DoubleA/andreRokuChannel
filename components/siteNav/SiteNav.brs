sub init()
    m.menuList = m.top.findNode("menuList")

    content = CreateObject("roSGNode", "ContentNode")
    for each page in PageRegistry()
        if page.type = "nav"
            item = content.createChild("ContentNode")
            item.setFields({ title: page.label, hdPosterUrl: page.icon })
        end if
    end for
    m.menuList.content = content
end sub

sub setFocusToList()
    m.menuList.setFocus(true)
end sub
