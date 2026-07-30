sub init()
    m.top.functionName = "fetchMovies"
end sub

sub fetchMovies()
    config = getMovieConfig()
    rows = getMoviePaths(config.baseUrl, config.apiKey)

    batchSize = m.top.batchSize
    if batchSize < 1 then batchSize = 5

    start = 0

    while start < rows.Count()
        batch = []
        i = start
        while i < rows.Count() and batch.Count() < batchSize
            batch.Push(rows[i])
            i = i + 1
        end while

        results = fetchBatch(batch)

        batchNode = CreateObject("roSGNode", "ContentNode")

        for each row in batch
            addMovieRow(batchNode, row.title, results[row.title])
        end for

        m.top.rowBatch = batchNode
        start = i
    end while
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
        end if
    end for

    while pending.Count() > 0
        msg = wait(0, port)
        if type(msg) = "roUrlEvent"
            id = msg.GetSourceIdentity().ToStr()
            entry = pending[id]
            if entry <> invalid
                if msg.GetResponseCode() = 200
                    results[entry.title] = ParseJson(msg.GetString())
                end if
                pending.Delete(id)
            end if
        else if msg = invalid
            for each id in pending
                pending[id].request.AsyncCancel()
            end for
            pending.Clear()
        end if
    end while

    return results
end function

sub addMovieRow(root as object, title as string, json as object)
    if json = invalid or json.results = invalid or json.results.Count() = 0 then return
    row = root.CreateChild("ContentNode")
    row.title = title
    for each movie in json.results
        item = row.CreateChild("ContentNode")
        item.title = movie.title
        item.SetField("description", movie.overview)
        if movie.backdrop_path <> invalid
            item.SetField("HDPosterUrl", "https://image.tmdb.org/t/p/w300" + movie.backdrop_path)
        else if movie.poster_path <> invalid
            item.SetField("HDPosterUrl", "https://image.tmdb.org/t/p/w342" + movie.poster_path)
        end if
        item.SetField("rating", movie.vote_average.ToStr())
        item.SetField("releaseDate", movie.release_date)
    end for
end sub
