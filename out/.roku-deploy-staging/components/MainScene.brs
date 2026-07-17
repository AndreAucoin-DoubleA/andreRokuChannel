sub init()
    m.top.backgroundColor = "#0f0f23"
    m.top.backgroundURI = ""

    m.sideBar = m.top.findNode("sideBar")
    m.contentArea = m.top.findNode("contentArea")
    m.contentSlide = m.top.findNode("contentSlide")
    m.contentSlideInterp = m.top.findNode("contentSlideInterp")

    m.global.observeField("navCollapsed", "onNavCollapsedChanged")

    m.pages = [
        m.top.findNode("homePage")
        m.top.findNode("moviesPage")
        m.top.findNode("gamesPage")
    ]

    m.currentPageIndex = 0
    m.focusOnSidebar = true

    m.sideBar.observeField("itemFocused", "onMenuFocused")
    m.sideBar.observeField("itemSelected", "onMenuSelected")

    m.sideBar.callFunc("setFocusToList")
end sub

sub onMenuFocused()
    showPage(m.sideBar.itemFocused)
end sub

sub onMenuSelected()
    showPage(m.sideBar.itemSelected)
end sub

sub onNavCollapsedChanged()
    if m.global.navCollapsed
        targetX = 200
    else
        targetX = 400
    end if

    currentPos = m.contentArea.translation
    m.contentSlideInterp.keyValue = [currentPos, [targetX, currentPos[1]]]
    m.contentSlide.control = "stop"
    m.contentSlide.control = "start"
end sub

sub showPage(index as integer)
    for i = 0 to m.pages.count() - 1
        m.pages[i].visible = (i = index)
    end for
    m.currentPageIndex = index
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    if key = "right" and m.focusOnSidebar
        m.focusOnSidebar = false
        m.sideBar.collapsed = true
        m.pages[m.currentPageIndex].setFocus(true)
        return true
    end if

    if key = "left" and m.focusOnSidebar = false
        m.focusOnSidebar = true
        m.sideBar.collapsed = false
        m.sideBar.callFunc("setFocusToList")
        return true
    end if

    return false
end function
