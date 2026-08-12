sub init()
    m.meta = m.top.findNode("meta")
    m.desc = m.top.findNode("desc")
    m.scrim = m.top.findNode("scrim")
    m.detailsBack = m.top.findNode("detailsBack")
    m.detailsBottomFade = m.top.findNode("detailsBottomFade")

    m.button = m.top.findNode("playButton")
    m.button.observeField("selected", "onButtonPressed")

    m.nextButton = m.top.findNode("nextButton")
    m.nextButton.observeField("selected", "onNextPressed")

    m.favButton = m.top.findNode("detailsFav")
    m.favButton.observeField("favorited", "onFavoriteToggled")

    m.backdropFadeAnim = m.top.findNode("backdropFadeAnim")
    m.backdropFadeInterp = m.top.findNode("backdropFadeInterp")
    m.overlayFadeAnim = m.top.findNode("overlayFadeAnim")
    m.overlayFadeInterp = m.top.findNode("overlayFadeInterp")

    m.bgTimer = m.top.findNode("bgPlayTimer")
    m.bgTimer.observeField("fire", "onBgTimerFire")

    m.video = m.top.findNode("videoPlayer")
    m.video.observeField("state", "onVideoStateChanged")

    m.bgActive = false
    m.fullscreenActive = false
    m.bgPlayed = false
    m.trailerFailed = false
    m.params = {}
    m.currentMovieId = ""
    m.returnFocus = invalid
    applyTheme()
end sub

sub applyTheme()
    t = Theme()

    m.scrim.color = t.color("component.movieDetails.scrimColor", "0x0F0F23FF")
    m.scrim.opacity = t.number("component.movieDetails.scrimOpacity", 0.96)

    m.meta.color = t.color("component.movieDetails.metaColor", "0xAAAACCFF")
    m.meta.font = t.font("component.movieDetails.metaTypography", "font:MediumSystemFont")

    m.desc.color = t.color("component.movieDetails.descriptionColor", "0xDDDDEEFF")
    m.desc.font = t.font("component.movieDetails.descriptionTypography", "font:MediumSystemFont")
end sub

sub viewDidLoad(params as object)
    m.params = params
    applyMovie(params.movie)
    m.nextButton.visible = (nextSibling() <> invalid)
end sub
sub viewWillAppear()
    beginAmbientCountdown()
end sub

sub viewWillHide()
    resetPlayback()
end sub

sub viewWillDisappear()
    resetPlayback()
end sub

function setViewFocus() as boolean
    return m.button.setFocus(true)
end function

sub applyMovie(movie as object)
    if movie = invalid then return

    m.meta.text = "Rating: " + movie.rating + "    Released: " + movie.releaseDate
    m.desc.text = movie.description
    m.detailsBack.uri = movie.HDBackgroundImageUrl

    m.currentMovieId = movie.movieId
    if m.currentMovieId = invalid then m.currentMovieId = ""

    m.favButton.favorited = isFavorite(m.currentMovieId)
end sub

sub onFavoriteToggled()
    if m.currentMovieId = "" then return

    favorited = m.favButton.favorited

    if favorited = isFavorite(m.currentMovieId) then return

    setFavorite(m.currentMovieId, favorited)
end sub

function nextSibling() as object
    if m.params.row = invalid or m.params.index = invalid then return invalid
    return m.params.row.getChild(m.params.index + 1)
end function

sub onNextPressed()
    nextMovie = nextSibling()
    if nextMovie = invalid then return

    pushView("MovieDetails", {
        movie: nextMovie,
        row: m.params.row,
        index: m.params.index + 1
    })
end sub

sub beginAmbientCountdown()
    resetPlayback()
    if m.trailerFailed then return
    m.bgPlayed = false
    m.bgTimer.control = "start"
end sub

sub resetPlayback()
    m.bgTimer.control = "stop"
    m.video.control = "stop"
    m.video.visible = false

    m.backdropFadeAnim.control = "stop"
    m.overlayFadeAnim.control = "stop"

    m.bgActive = false
    m.fullscreenActive = false

    m.detailsBack.opacity = 1
    m.detailsBottomFade.opacity = 1
    m.meta.visible = true
    m.desc.visible = true
    m.button.visible = true
    m.favButton.visible = true
    m.nextButton.visible = (nextSibling() <> invalid)
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

    if not m.bgActive then startTrailer()
    m.bgActive = false
    m.fullscreenActive = true
    m.bgPlayed = true

    m.video.setFocus(true)

    m.meta.visible = false
    m.desc.visible = false
    m.button.visible = false
    m.favButton.visible = false
    m.nextButton.visible = false
    fadeBackdrop(0)
    fadeOverlay(0)
end sub

sub onVideoStateChanged()
    state = m.video.state

    if state = "error"
        m.trailerFailed = true
        resetPlayback()
        m.button.setFocus(true)
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
    m.favButton.visible = true
    m.nextButton.visible = (nextSibling() <> invalid)
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

    if m.fullscreenActive then return false

    if key = "right" and not m.favButton.hasFocus()
        m.returnFocus = focusedColumnControl()
        m.favButton.setFocus(true)
        return true
    end if

    if key = "left" and m.favButton.hasFocus()
        target = m.returnFocus
        if target = invalid then target = m.button

        target.setFocus(true)
        return true
    end if

    if key = "down" then return moveFocus(1)
    if key = "up" then return moveFocus(-1)

    return false
end function

function focusChain() as object
    chain = [m.button]
    if m.nextButton.visible then chain.Push(m.nextButton)

    return chain
end function

function focusedColumnControl() as object
    for each control in focusChain()
        if control.hasFocus() then return control
    end for

    return m.button
end function

function moveFocus(delta as integer) as boolean
    chain = focusChain()

    for idx = 0 to chain.Count() - 1
        if chain[idx].hasFocus()
            target = idx + delta
            if target < 0 or target >= chain.Count() then return false

            chain[target].setFocus(true)
            return true
        end if
    end for

    return false
end function
