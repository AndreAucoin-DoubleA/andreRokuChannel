sub init()
    m.top.functionName = "fetchMovies"
end sub

sub fetchMovies()
    config = getMovieConfig()
    rows = getMoviePaths(config.baseUrl, config.apiKey)

    port = CreateObject("roMessagePort")
    pending = {}
    results = {}

    for each row in rows
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

    root = CreateObject("roSGNode", "ContentNode")
    for each row in rows
        addMovieRow(root, row.title, results[row.title])
    end for

    m.top.content = root
end sub

sub addMovieRow(root as object, title as string, json as object)
    row = root.CreateChild("ContentNode")
    row.title = title
    if json = invalid then return

    for each movie in json.results
        item = row.CreateChild("ContentNode")
        item.title = movie.title
        item.SetField("description", movie.overview)

        if movie.poster_path <> invalid
            item.SetField("HDPosterUrl", "https://image.tmdb.org/t/p/w500" + movie.poster_path)
        end if

        item.SetField("rating", movie.vote_average.ToStr())
        item.SetField("releaseDate", movie.release_date)
    end for
end sub
