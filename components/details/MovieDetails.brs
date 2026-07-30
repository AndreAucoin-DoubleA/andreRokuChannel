sub init()
    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")
    m.meta = m.top.findNode("meta")
    m.desc = m.top.findNode("desc")
    m.button = m.top.findNode("playButton")
    m.button.observeField("selected", "onButtonPressed")

    m.video = m.top.findNode("videoPlayer")
    m.video.observeField("state", "onVideoStateChanged")
end sub

sub focusPlayButton()
    m.button.setFocus(true)
end sub

sub onMovieContentChanged()
    movie = m.top.movieContent
    if movie = invalid then return

    m.poster.uri = movie.HDPosterUrl
    m.title.text = movie.title
    m.meta.text = "Rating: " + movie.rating + "    Released: " + movie.releaseDate
    m.desc.text = movie.description
end sub

sub onButtonPressed()
    content = CreateObject("roSGNode", "ContentNode")
    content.url = "https://media.w3.org/2010/05/bunny/trailer.mp4"
    content.streamFormat = "mp4"

    m.video.content = content
    m.video.visible = true
    m.video.control = "play"
    m.video.setFocus(true)
end sub

sub onVideoStateChanged()
    state = m.video.state

    if state = "error"
        return
    end if

    if state = "finished"
        m.video.visible = false
        m.button.setFocus(true)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false
    if m.video.visible
        if key = "back"
            m.video.control = "stop"
            m.video.visible = false
            m.button.setFocus(true)
            return true
        end if
    end if
    return false
end function
