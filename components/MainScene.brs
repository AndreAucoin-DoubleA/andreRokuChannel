sub init()
    m.top.backgroundColor = "#0f0f23"
    m.top.findNode("sceneBackground").uri = Theme().backgroundUri

    m.sideBar = m.top.findNode("sideBar")
    m.contentArea = m.top.findNode("contentArea")
    m.contentSlide = m.top.findNode("contentSlide")
    m.contentSlideInterp = m.top.findNode("contentSlideInterp")
    m.global.observeField("navCollapsed", "onNavCollapsedChanged")

    m.registry = PageRegistry()
    m.navPages = []
    for each entry in m.registry
        if entry.type = "nav" then m.navPages.push(entry)
    end for

    m.pageCache = {}
    m.currentPage = invalid
    m.details = invalid
    m.detailsOpen = false
    m.focusOnSidebar = true

    m.sideBar.observeField("itemFocused", "onMenuFocused")

    m.sideBar.callFunc("setFocusToList")
end sub

sub onMenuFocused()
    showPage(m.sideBar.itemFocused)
end sub

sub onNavCollapsedChanged()
    targetX = 400
    if m.global.navCollapsed then targetX = 200

    currentPos = m.contentArea.translation
    m.contentSlideInterp.keyValue = [currentPos, [targetX, currentPos[1]]]
    m.contentSlide.control = "stop"
    m.contentSlide.control = "start"
end sub

sub showPage(index as integer)
    entry = m.navPages[index]
    if entry = invalid then return

    page = getPageNode(entry)

    for each id in m.pageCache
        m.pageCache[id].visible = (id = entry.id)
    end for
    m.currentPage = page
end sub

function getPageNode(entry as object) as object
    node = m.pageCache[entry.id]
    if node <> invalid then return node

    parent = m.contentArea
    if entry.type = "overlay" then parent = m.top

    node = parent.createChild(entry.component)
    node.visible = false
    m.pageCache[entry.id] = node

    if node.hasField("selectedMovie")
        node.observeField("selectedMovie", "onMovieSelected")
    end if

    return node
end function

function pageById(id as string) as object
    for each entry in m.registry
        if entry.id = id then return entry
    end for
    return invalid
end function

sub onMovieSelected(msg as object)
    movie = msg.getData()
    if movie = invalid then return

    m.details = getPageNode(pageById("details"))
    m.details.movieContent = movie
    m.details.visible = true
    m.details.setFocus(true)
    m.detailsOpen = true
end sub

sub focusContentArea()
    m.focusOnSidebar = false
    m.sideBar.collapsed = true
    if m.currentPage <> invalid then m.currentPage.callFunc("focusContent")
end sub

sub focusSidebar()
    m.focusOnSidebar = true
    m.sideBar.collapsed = false
    m.sideBar.callFunc("setFocusToList")
end sub

sub closeDetails()
    m.details.visible = false
    m.detailsOpen = false
    if m.currentPage <> invalid then m.currentPage.callFunc("focusContent")
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    if m.detailsOpen
        if key = "back" then closeDetails()
        return true
    end if

    if key = "right" and m.focusOnSidebar
        focusContentArea()
        return true
    end if

    if key = "left" and not m.focusOnSidebar
        focusSidebar()
        return true
    end if

    return false
end function
