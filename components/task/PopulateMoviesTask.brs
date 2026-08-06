sub init()
    m.top.functionName = "fetchMovies"
end sub

sub fetchMovies()
    print "[PopulateMoviesTask] fetchMovies: start"

    config = getMovieConfig()
    rows = getMoviePaths(config.baseUrl, config.apiKey)
    print "[PopulateMoviesTask] fetchMovies: " ; rows.Count() ; " category rows to fetch"

    batchSize = m.top.batchSize
    if batchSize < 1 then batchSize = 5

    start = 0
    batchNum = 0

    while start < rows.Count()
        batchNum = batchNum + 1
        batch = []
        i = start
        while i < rows.Count() and batch.Count() < batchSize
            batch.Push(rows[i])
            i = i + 1
        end while

        print "[PopulateMoviesTask] batch " ; batchNum ; ": fetching rows " ; start ; "-" ; (i - 1)
        results = fetchBatch(batch)
        print "[PopulateMoviesTask] batch " ; batchNum ; ": fetchBatch returned " ; results.Count() ; " result(s)"

        batchNode = CreateObject("roSGNode", "ContentNode")

        for each row in batch
            addMovieRow(batchNode, row.title, results[row.title])
        end for

        print "[PopulateMoviesTask] batch " ; batchNum ; ": publishing rowBatch with " ; batchNode.GetChildCount() ; " row(s)"
        m.top.rowBatch = batchNode
        start = i
    end while

    print "[PopulateMoviesTask] fetchMovies: loadComplete"
    m.top.loadComplete = true
end sub

function fetchBatch(batch as object) as object
    port = CreateObject("roMessagePort")
    pending = {}
    results = {}

    for each row in batch
        request = CreateObject("roUrlTransfer")
        request.SetMessagePort(port)
        request.SetCertificatesFile("common:/certs/ca-bundle.crt")
        request.InitClientCertificates()
        request.SetUrl(row.path)

        if request.AsyncGetToString()
            id = request.GetIdentity().ToStr()
            pending[id] = { request: request, title: row.title }
            print "[PopulateMoviesTask]   requested '" ; row.title ; "' (id=" ; id ; ")"
        else
            print "[PopulateMoviesTask]   AsyncGetToString FAILED to start for '" ; row.title ; "'"
        end if
    end for

    while pending.Count() > 0
        msg = wait(10000, port)
        if type(msg) = "roUrlEvent"
            id = msg.GetSourceIdentity().ToStr()
            entry = pending[id]
            if entry <> invalid
                code = msg.GetResponseCode()
                print "[PopulateMoviesTask]   response for '" ; entry.title ; "' code=" ; code
                if code = 200
                    results[entry.title] = ParseJson(msg.GetString())
                end if
                pending.Delete(id)
            else
                print "[PopulateMoviesTask]   response for unknown id=" ; id
            end if
        else if msg = invalid
            print "[PopulateMoviesTask]   TIMED OUT waiting for " ; pending.Count() ; " pending request(s) - cancelling"
            for each id in pending
                print "[PopulateMoviesTask]     cancelling '" ; pending[id].title ; "'"
                pending[id].request.AsyncCancel()
            end for
            pending.Clear()
        end if
    end while

    return results
end function

sub addMovieRow(root as object, title as string, json as object)
    if json = invalid or json.results = invalid or json.results.Count() = 0
        print "[PopulateMoviesTask]   addMovieRow: '" ; title ; "' has no usable results, skipping"
        return
    end if

    row = root.CreateChild("ContentNode")
    row.title = title

    for each movie in json.results
        item = row.CreateChild("ContentNode")
        item.title = movie.title

        movieId = ""
        if movie.id <> invalid then movieId = movie.id.ToStr()
        item.AddFields({ movieId: movieId })

        item.SetField("description", movie.overview)
        if movie.backdrop_path <> invalid
            item.SetField("HDPosterUrl", "https://image.tmdb.org/t/p/w300" + movie.backdrop_path)
            item.SetField("HDBackgroundImageUrl", "https://image.tmdb.org/t/p/w1280" + movie.backdrop_path)
        else if movie.poster_path <> invalid
            item.SetField("HDPosterUrl", "https://image.tmdb.org/t/p/w342" + movie.poster_path)
            item.SetField("HDBackgroundImageUrl", "https://image.tmdb.org/t/p/w780" + movie.poster_path)
        end if
        item.SetField("rating", movie.vote_average.ToStr())
        item.SetField("releaseDate", movie.release_date)
    end for
    print "[PopulateMoviesTask]   addMovieRow: '" ; title ; "' added " ; json.results.Count() ; " movie(s)"
end sub
