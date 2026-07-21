sub init()
    m.top.functionName = "fetchMovies"
end sub

sub fetchMovies()
    config = getMovieConfig()
    url = config.baseUrl + "/movie/popular?api_key=" + config.apiKey + "&page=1"

    request = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")

    request.SetMessagePort(port)
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")

    request.InitClientCertificates()
    request.SetUrl(url)

    if request.AsyncGetToString()
        while true
            msg = wait(0, port)
            if type(msg) = "roUrlEvent"
                code = msg.GetResponseCode()

                if code = 200
                    json = ParseJson(msg.GetString())
                    content = BuildMoviesContentNode(json)
                    print "DEBUG built rows: "; content.GetChildCount(); " items in row 0: "; content.GetChild(0).GetChildCount()
                    m.top.content = content
                else
                    print "TMDB request failed with code: "; code
                    m.top.content = invalid
                end if
                exit while
            else if msg = invalid
                request.AsyncCancel()
                exit while
            end if
        end while
    end if
end sub

function BuildMoviesContentNode(json as object) as object
    root = CreateObject("roSGNode", "ContentNode")
    row = root.CreateChild("ContentNode")

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
    return root
end function

