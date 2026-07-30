sub init()
    m.rowList = m.top.findNode("rowList")
    m.loadingLabel = m.top.findNode("loadingLabel")
    m.heroGroup = m.top.findNode("heroGroup")
    m.itemSelectBackground = m.top.findNode("itemSelectBackground")
    m.movieLogo = m.top.findNode("movieLogo")
    m.movieTitleLabel = m.top.findNode("movieTitleLabel")
    m.heroFadeAnim = m.top.findNode("heroFadeAnim")
    m.loaded = false
    m.heroSeeded = false
    m.top.observeField("visible", "onVisibleChanged")
    m.rowList.observeField("rowItemSelected", "onMovieSelected")
    m.rowList.observeField("rowItemFocused", "onMovieFocused")

    m.rootContent = CreateObject("roSGNode", "ContentNode")
    m.rowList.content = m.rootContent

    m.logoCache = {}
    m.currentTransitionKey = ""
    m.currentMovieId = invalid
    m.backdropReady = false
    m.logoReady = false
    m.logoIsImage = false
    m.pendingBackdropUri = ""
    m.pendingLogoUri = ""

    m.itemSelectBackground.observeField("loadStatus", "onBackdropLoadStatusChanged")
    m.movieLogo.observeField("loadStatus", "onLogoLoadStatusChanged")

    m.logoTask = CreateObject("roSGNode", "FetchMovieLogoTask")
    m.logoTask.observeField("logoUrl", "onLogoFetched")
end sub

function movieAt(sel as object) as object
    if sel = invalid or sel.Count() < 2 then return invalid

    row = m.rootContent.getChild(sel[0])
    if row = invalid then return invalid

    return row.getChild(sel[1])
end function

sub onMovieSelected()
    movie = movieAt(m.rowList.rowItemSelected)
    if movie = invalid then return

    m.top.selectedMovie = movie
end sub

sub onMovieFocused()
    movie = movieAt(m.rowList.rowItemFocused)
    if movie = invalid then return

    beginMovieTransition(movie)
end sub

sub beginMovieTransition(movie as object)
    movieIdStr = movie.movieId
    if movieIdStr = invalid then movieIdStr = ""
    key = movie.title + "|" + movieIdStr
    if key = m.currentTransitionKey then return
    m.currentTransitionKey = key

    m.currentMovieId = movie.movieId
    m.currentLogoTitle = movie.title
    m.backdropReady = false
    m.logoReady = false

    m.heroFadeAnim.control = "stop"
    m.heroGroup.opacity = 0
    m.heroGroup.visible = false
    m.itemSelectBackground.visible = false
    m.movieLogo.visible = false
    m.movieTitleLabel.visible = false

    loadBackdrop(movie)
    loadLogo(movie)
end sub

sub loadBackdrop(movie as object)
    uri = movie.HDBackgroundImageUrl
    m.pendingBackdropUri = uri

    if uri = invalid or uri = ""
        m.backdropReady = true
        tryReveal()
        return
    end if

    if m.itemSelectBackground.uri = uri and m.itemSelectBackground.loadStatus = "ready"
        m.backdropReady = true
        tryReveal()
        return
    end if

    m.itemSelectBackground.uri = uri
end sub

sub onBackdropLoadStatusChanged()
    status = m.itemSelectBackground.loadStatus
    if status <> "ready" and status <> "failed" then return
    if m.itemSelectBackground.uri <> m.pendingBackdropUri then return

    m.backdropReady = true
    tryReveal()
end sub

sub loadLogo(movie as object)
    movieId = movie.movieId

    if movieId = invalid or movieId = ""
        useTextFallback()
        return
    end if

    cached = m.logoCache[movieId]
    if cached <> invalid
        applyCachedLogo(cached)
        return
    end if

    config = getMovieConfig()
    m.logoTask.control = "stop"
    m.logoTask.baseUrl = config.baseUrl
    m.logoTask.apiKey = config.apiKey
    m.logoTask.movieId = movieId
    m.logoTask.control = "RUN"
end sub

sub onLogoFetched(msg as object)
    task = msg.GetRoSGNode()
    movieId = task.movieId
    logoUrl = msg.GetData()

    m.logoCache[movieId] = logoUrl
    if movieId <> m.currentMovieId then return

    applyCachedLogo(logoUrl)
end sub

sub applyCachedLogo(logoUrl as string)
    if logoUrl = invalid or logoUrl = ""
        useTextFallback()
        return
    end if

    m.logoIsImage = true
    m.pendingLogoUri = logoUrl

    if m.movieLogo.uri = logoUrl and m.movieLogo.loadStatus = "ready"
        m.logoReady = true
        tryReveal()
        return
    end if

    m.movieLogo.uri = logoUrl
end sub

sub onLogoLoadStatusChanged()
    status = m.movieLogo.loadStatus
    if status <> "ready" and status <> "failed" then return
    if m.movieLogo.uri <> m.pendingLogoUri then return

    if status = "failed"
        useTextFallback()
        return
    end if

    m.logoReady = true
    tryReveal()
end sub

sub useTextFallback()
    m.logoIsImage = false
    m.movieTitleLabel.text = m.currentLogoTitle
    m.logoReady = true
    tryReveal()
end sub

sub tryReveal()
    if not m.backdropReady or not m.logoReady then return

    m.itemSelectBackground.visible = true
    m.movieLogo.visible = m.logoIsImage
    m.movieTitleLabel.visible = not m.logoIsImage

    m.heroGroup.visible = true
    m.heroFadeAnim.control = "start"
end sub

sub onRowBatchReady(msg as object)
    print "[MoviesPage] onRowBatchReady fired"
    batch = msg.GetData()
    if batch = invalid
        print "[MoviesPage] onRowBatchReady: batch data was invalid"
        return
    end if

    kids = batch.GetChildren(-1, 0)
    print "[MoviesPage] onRowBatchReady: " ; kids.Count() ; " row(s) in this batch"
    if kids.Count() = 0 then return

    batch.RemoveChildren(kids)
    m.rootContent.AppendChildren(kids)
    m.loadingLabel.visible = false

    if not m.heroSeeded
        firstRow = m.rootContent.getChild(0)
        if firstRow <> invalid and firstRow.getChild(0) <> invalid
            m.heroSeeded = true
            beginMovieTransition(firstRow.getChild(0))
        end if
    end if
end sub

sub onVisibleChanged()
    if m.top.visible and not m.loaded
        print "[MoviesPage] onVisibleChanged: starting PopulateMoviesTask"
        m.loaded = true
        m.loadingLabel.visible = true
        m.movieTask = CreateObject("roSGNode", "PopulateMoviesTask")
        m.movieTask.batchSize = 5
        m.movieTask.observeField("rowBatch", "onRowBatchReady")
        m.movieTask.observeField("loadComplete", "onLoadComplete")
        m.movieTask.control = "RUN"
    end if
end sub

function focusContent() as boolean
    return m.rowList.setFocus(true)
end function

sub onLoadComplete()
    print "[MoviesPage] onLoadComplete fired, rootContent has " ; m.rootContent.GetChildCount() ; " row(s)"
    if m.rootContent.GetChildCount() = 0
        m.loadingLabel.text = "Couldn't load movies"
        m.loadingLabel.visible = true
    end if
end sub
