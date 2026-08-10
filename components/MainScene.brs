sub init()
    m.top.findNode("sceneBackground").uri = AppAssets().backgroundUri

    m.sideBar = m.top.findNode("sideBar")
    m.chrome = m.top.findNode("chrome")
    m.navFade = m.top.findNode("navFade")
    m.navFadeAnim = m.top.findNode("navFadeAnim")
    m.navFadeWidthInterp = m.top.findNode("navFadeWidthInterp")
    m.navFadeOpacityInterp = m.top.findNode("navFadeOpacityInterp")

    m.screens = m.top.findNode("screens")
    m.screens.stackContainer = m.top.findNode("stackLayer")
    m.screens.observeField("activeDepth", "onActiveDepthChanged")

    applyTheme()

    m.global.observeField("designTokens", "applyTheme")
    m.global.observeField("navCollapsed", "onNavCollapsedChanged")

    m.navPages = []
    for each entry in PageRegistry()
        if entry.type = "nav" then m.navPages.push(entry)
    end for

    m.focusOnSidebar = true
    m.sideBar.observeField("itemFocused", "onMenuFocused")

    m.screens.callFunc("showStack", m.navPages[0].id)
    focusContentArea()
end sub

sub applyTheme()
    t = Theme(true)

    m.top.backgroundColor = t.color("component.scene.backgroundColor", "0x0F0F23FF")

    m.navRailExpanded = t.size("component.scene.navRailExpanded", 420)
    m.navRailCollapsed = t.size("component.scene.navRailCollapsed", 140)
end sub

sub onMenuFocused()
    entry = m.navPages[m.sideBar.itemFocused]
    if entry = invalid then return
    m.screens.callFunc("showStack", entry.id)
end sub

sub onActiveDepthChanged()
    m.chrome.visible = (m.screens.activeDepth <= 1)
end sub

sub onNavCollapsedChanged()
    if m.global.navCollapsed
        targetWidth = m.navRailCollapsed
        targetOpacity = 0.3
    else
        targetWidth = m.navRailExpanded
        targetOpacity = 0.88
    end if

    m.navFadeWidthInterp.keyValue = [m.navFade.width, targetWidth]
    m.navFadeOpacityInterp.keyValue = [m.navFade.opacity, targetOpacity]
    m.navFadeAnim.control = "stop"
    m.navFadeAnim.control = "start"
end sub

sub focusContentArea()
    m.focusOnSidebar = false
    m.global.navCollapsed = true
    m.screens.callFunc("focusActive")
end sub

sub focusSidebar()
    m.focusOnSidebar = true
    m.global.navCollapsed = false
    m.sideBar.callFunc("setFocusToList")
end sub

sub customSuspend(arg as dynamic)
    m.screens.callFunc("suspendActive")
end sub

sub customResume(arg as dynamic)
    m.screens.callFunc("resumeActive")

    if m.focusOnSidebar
        m.sideBar.callFunc("setFocusToList")
    else
        m.screens.callFunc("focusActive")
    end if

    m.top.signalBeacon("AppResumeComplete")
end sub


function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    if key = "back"
        if not m.focusOnSidebar
            focusSidebar()
            return true
        end if
        return false
    end if

    if m.screens.activeDepth > 1 then return false

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
