sub init()
    m.meta = m.top.findNode("meta")
    m.desc = m.top.findNode("desc")
    m.detailsBack = m.top.findNode("detailsBack")
    m.detailsBottomFade = m.top.findNode("detailsBottomFade")
    m.button = m.top.findNode("playButton")
    m.button.observeField("selected", "onButtonPressed")

    m.backdropFadeAnim = m.top.findNode("backdropFadeAnim")
    m.backdropFadeInterp = m.top.findNode("backdropFadeInterp")
    m.overlayFadeAnim = m.top.findNode("overlayFadeAnim")
    m.overlayFadeInterp = m.top.findNode("overlayFadeInterp")

    m.bgTimer = m.top.findNode("bgPlayTimer")
    m.bgTimer.observeField("fire", "onBgTimerFire")

    m.video = m.top.findNode("videoPlayer")
    m.video.observeField("state", "onVideoStateChanged")

    m.top.observeField("visible", "onVisibleChanged")

    m.bgActive = false
    m.fullscreenActive = false
    m.bgPlayed = false
end sub

sub fadeBackdrop(target as float)
    m.backdropFadeAnim.control = "stop"
    m.backdropFadeInterp.keyValue = [m.detailsBack.opacity, target]
    m.backdropFadeAnim.control = "start"
end sub

sub fadeOverlay(target as float)
    m.overlayFadeAnim.control = "stop"
    m.overlayFadeInterp.keyValue = [m.detailsBottomFade.opacity, target]
    m.overlayFadeAnim.control = "start"
end sub

sub focusPlayButton()
    m.button.setFocus(true)
end sub

sub onMovieContentChanged()
    movie = m.top.movieContent
    if movie = invalid then return

    m.meta.text = "Rating: " + movie.rating + "    Released: " + movie.releaseDate
    m.desc.text = movie.description
    m.detailsBack.uri = movie.HDBackgroundImageUrl
end sub

sub onVisibleChanged()
    resetPlayback()

    if m.top.visible
        m.bgPlayed = false
        m.bgTimer.control = "start"
    end if
end sub

sub resetPlayback()
    m.bgTimer.control = "stop"
    m.video.control = "stop"
    m.video.visible = false

    m.bgActive = false
    m.fullscreenActive = false

    m.detailsBack.opacity = 1
    m.detailsBottomFade.opacity = 1
    m.meta.visible = true
    m.desc.visible = true
    m.button.visible = true
end sub

sub startTrailer()
    content = CreateObject("roSGNode", "ContentNode")
    content.url = "https://media.w3.org/2010/05/bunny/trailer.mp4"
    content.streamFormat = "mp4"

    m.video.content = content
    m.video.visible = true
    m.video.control = "play"
end sub

sub onBgTimerFire()
    if m.fullscreenActive or m.bgPlayed then return

    startTrailer()
    m.bgActive = true
    m.bgPlayed = true
    fadeBackdrop(0)
end sub

sub onButtonPressed()
    m.bgTimer.control = "stop"

    startTrailer()

    m.bgActive = false
    m.fullscreenActive = true
    m.bgPlayed = true

    m.video.setFocus(true)

    m.meta.visible = false
    m.desc.visible = false
    m.button.visible = false
    fadeBackdrop(0)
    fadeOverlay(0)
end sub

sub onVideoStateChanged()
    state = m.video.state

    if state = "error"
        return
    end if

    if state = "finished"
        m.video.control = "stop"
        m.video.visible = false

        if m.fullscreenActive
            restoreDetails()
        else if m.bgActive
            m.bgActive = false
            fadeBackdrop(1)
        end if
    end if
end sub

sub restoreDetails()
    m.fullscreenActive = false
    m.meta.visible = true
    m.desc.visible = true
    m.button.visible = true
    fadeBackdrop(1)
    fadeOverlay(1)
    m.button.setFocus(true)

    m.bgPlayed = false
    m.bgTimer.control = "start"
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    if m.fullscreenActive and key = "back"
        m.video.control = "stop"
        m.video.visible = false
        restoreDetails()
        return true
    end if

    return false
end function
