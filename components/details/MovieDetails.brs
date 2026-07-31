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

    m.mode = "idle"
    m.bgPlayed = false
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
    resetDetails()
    if m.top.visible then armBgTrailer()
end sub

sub onButtonPressed()
    goFullscreen()
end sub

sub onBgTimerFire()
    if m.mode <> "idle" or m.bgPlayed then return
    goBackground()
end sub

sub onVideoStateChanged()
    if m.video.state <> "finished" then return

    if m.mode = "fullscreen"
        exitFullscreen()
    else if m.mode = "bg"
        restoreDetails()
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    if m.mode = "fullscreen" and key = "back"
        exitFullscreen()
        return true
    end if

    return false
end function

sub goBackground()
    m.mode = "bg"
    playTrailer()
    fadeBackdrop(0)
end sub

sub goFullscreen()
    m.mode = "fullscreen"
    m.bgTimer.control = "stop"
    playTrailer()
    m.video.setFocus(true)
    showChrome(false)
    fadeBackdrop(0)
    fadeOverlay(0)
end sub

sub exitFullscreen()
    restoreDetails()
    armBgTrailer()
end sub

sub restoreDetails()
    m.mode = "idle"
    stopVideo()
    showChrome(true)
    fadeBackdrop(1)
    fadeOverlay(1)
    m.button.setFocus(true)
end sub

sub resetDetails()
    m.mode = "idle"
    m.bgTimer.control = "stop"
    stopVideo()
    stopFades()
    m.detailsBack.opacity = 1
    m.detailsBottomFade.opacity = 1
    showChrome(true)
end sub

sub armBgTrailer()
    m.bgPlayed = false
    m.bgTimer.control = "start"
end sub

sub playTrailer()
    content = CreateObject("roSGNode", "ContentNode")
    content.url = "https://media.w3.org/2010/05/bunny/trailer.mp4"
    content.streamFormat = "mp4"

    m.video.content = content
    m.video.visible = true
    m.video.control = "play"
    m.bgPlayed = true
end sub

sub stopVideo()
    m.video.control = "stop"
    m.video.visible = false
end sub

sub showChrome(show as boolean)
    m.meta.visible = show
    m.desc.visible = show
    m.button.visible = show
end sub

sub stopFades()
    m.backdropFadeAnim.control = "stop"
    m.overlayFadeAnim.control = "stop"
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
