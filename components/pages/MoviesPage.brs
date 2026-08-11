sub init()
    m.rowList = m.top.findNode("rowList")
    m.loadingLabel = m.top.findNode("loadingLabel")
    m.heroGroup = m.top.findNode("heroGroup")
    m.backdrop = m.top.findNode("itemSelectBackground")
    m.movieLogo = m.top.findNode("movieLogo")
    m.movieTitleLabel = m.top.findNode("movieTitleLabel")
    m.heroFadeAnim = m.top.findNode("heroFadeAnim")
    m.heroDebounce = m.top.findNode("heroDebounce")
    m.inputGateTimeout = m.top.findNode("inputGateTimeout")

    m.rootContent = CreateObject("roSGNode", "ContentNode")
    m.rowList.content = m.rootContent

    m.logoCache = {}
    m.stagedRows = []
    m.logoTask = invalid
    m.movieTask = invalid
    m.currentMovieId = ""
    m.pendingMovie = invalid
    m.inputLocked = true

    m.rowList.observeField("rowItemSelected", "onMovieSelected")
    m.rowList.observeField("rowItemFocused", "onMovieFocused")
    m.heroDebounce.observeField("fire", "onHeroDebounceFired")
    m.inputGateTimeout.observeField("fire", "releaseInputGate")
    m.backdrop.observeField("loadStatus", "onBackdropLoadStatus")
    m.movieLogo.observeField("loadStatus", "onLogoLoadStatus")

    applyTheme()
end sub

sub applyTheme()
    t = Theme()

    m.loadingLabel.color = t.color("component.page.statusTextColor", "0xAAAACCFF")
    m.loadingLabel.font = t.font("component.page.statusTextTypography", "font:MediumSystemFont")

    m.movieTitleLabel.color = t.color("component.page.heroTitleColor", "0xFFFFFFFF")
    m.movieTitleLabel.font = t.font("component.page.heroTitleTypography", "font:LargeBoldSystemFont")

    m.rowList.rowItemSize = [[t.size("component.moviePoster.width", 376), t.size("component.moviePoster.height", 220)]]
end sub

sub viewDidLoad(params as object)
    if m.movieTask <> invalid then return

    m.loadingLabel.visible = true
    m.inputGateTimeout.control = "start"

    m.movieTask = CreateObject("roSGNode", "PopulateMoviesTask")
    m.movieTask.batchSize = 5
    m.movieTask.observeField("rowBatch", "onRowBatchReady")
    m.movieTask.observeField("loadComplete", "onLoadComplete")
    m.movieTask.control = "RUN"
end sub

sub onRowBatchReady(msg as object)
    batch = msg.GetData()
    if batch = invalid then return

    kids = batch.GetChildren(-1, 0)
    if kids.Count() = 0 then return

    batch.RemoveChildren(kids)

    if m.rootContent.getChildCount() > 0
        m.stagedRows.Append(kids)
        return
    end if

    m.rootContent.AppendChildren(kids)
    m.loadingLabel.visible = false
    showHero(kids[0].getChild(0))
end sub

sub onLoadComplete()
    if m.stagedRows.Count() > 0
        m.rootContent.AppendChildren(m.stagedRows)
        m.stagedRows = []
    end if

    if m.rootContent.getChildCount() > 0 then return

    m.loadingLabel.text = "Couldn't load movies"
    m.loadingLabel.visible = true
    releaseInputGate()
end sub

function movieAt(sel as object) as object
    if sel = invalid or sel.Count() < 2 then return invalid

    row = m.rootContent.getChild(sel[0])
    if row = invalid then return invalid

    return row.getChild(sel[1])
end function

sub onMovieFocused()
    movie = movieAt(m.rowList.rowItemFocused)
    if movie = invalid then return

    m.pendingMovie = movie
    m.heroDebounce.control = "stop"
    m.heroDebounce.control = "start"
end sub

sub onHeroDebounceFired()
    if m.pendingMovie = invalid then return

    movie = m.pendingMovie
    m.pendingMovie = invalid
    showHero(movie)
end sub

sub showHero(movie as object)
    if movie = invalid then return

    movieId = movie.movieId
    if movieId = invalid then movieId = ""
    if movieId <> "" and movieId = m.currentMovieId then return
    m.currentMovieId = movieId

    uri = movie.HDBackgroundImageUrl
    if uri = invalid then uri = ""

    m.heroFadeAnim.control = "stop"
    m.heroGroup.opacity = 0
    m.backdrop.uri = uri

    showLogo(movie, movieId)

    if uri = "" then revealHero()
end sub

sub onBackdropLoadStatus()
    status = m.backdrop.loadStatus
    if status <> "ready" and status <> "failed" then return

    revealHero()
end sub

sub revealHero()
    m.heroFadeAnim.control = "start"
    releaseInputGate()
end sub

sub showLogo(movie as object, movieId as string)
    m.movieTitleLabel.text = movie.title

    if movieId = ""
        applyLogo(invalid)
        return
    end if

    cached = m.logoCache[movieId]
    if cached <> invalid
        applyLogo(cached)
        return
    end if

    m.movieLogo.visible = false
    m.movieTitleLabel.visible = false
    startLogoFetch(movieId)
end sub

sub applyLogo(logoUrl as dynamic)
    hasLogo = (logoUrl <> invalid and logoUrl <> "")

    if hasLogo then m.movieLogo.uri = logoUrl
    m.movieLogo.visible = hasLogo
    m.movieTitleLabel.visible = not hasLogo
end sub

sub onLogoLoadStatus()
    if m.movieLogo.loadStatus <> "failed" then return

    m.movieLogo.visible = false
    m.movieTitleLabel.visible = true
end sub

sub startLogoFetch(movieId as string)
    cancelLogoFetch()

    task = CreateObject("roSGNode", "FetchMovieLogoTask")
    task.movieId = movieId
    task.observeField("logoUrl", "onLogoFetched")
    m.logoTask = task
    task.control = "RUN"
end sub

sub cancelLogoFetch()
    if m.logoTask = invalid then return

    m.logoTask.unobserveField("logoUrl")
    m.logoTask.control = "stop"
    m.logoTask = invalid
end sub

sub onLogoFetched(msg as object)
    movieId = msg.GetRoSGNode().movieId
    logoUrl = msg.GetData()

    m.logoCache[movieId] = logoUrl

    if movieId = m.currentMovieId then applyLogo(logoUrl)
end sub


function setViewFocus() as boolean
    if m.inputLocked then return m.top.setFocus(true)

    return m.rowList.setFocus(true)
end function

function onKeyEvent(key as string, press as boolean) as boolean
    if not m.inputLocked or not press then return false

    return key = "up" or key = "down" or key = "right" or key = "OK"
end function

sub releaseInputGate()
    if not m.inputLocked then return

    m.inputLocked = false
    m.inputGateTimeout.control = "stop"

    if m.top.isInFocusChain() then m.rowList.setFocus(true)
end sub

sub onMovieSelected()
    sel = m.rowList.rowItemSelected
    movie = movieAt(sel)
    if movie = invalid then return

    pushView("MovieDetails", { movie: movie, row: m.rootContent.getChild(sel[0]), index: sel[1] })
end sub

sub viewWillDisappear()
    m.heroDebounce.control = "stop"
    m.inputGateTimeout.control = "stop"
    m.pendingMovie = invalid

    cancelLogoFetch()

    if m.movieTask = invalid then return

    m.movieTask.unobserveField("rowBatch")
    m.movieTask.unobserveField("loadComplete")
    m.movieTask.control = "stop"
    m.movieTask = invalid
end sub

