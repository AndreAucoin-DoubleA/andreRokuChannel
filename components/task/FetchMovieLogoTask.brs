sub init()
    m.top.functionName = "fetchLogo"
end sub

sub fetchLogo()
    movieId = m.top.movieId
    if movieId = invalid or movieId = ""
        m.top.logoUrl = ""
        return
    end if

    url = m.top.baseUrl + "/movie/" + movieId + "/images?api_key=" + m.top.apiKey

    request = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    request.SetMessagePort(port)
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.InitClientCertificates()
    request.SetUrl(url)

    logoUrl = ""

    if request.AsyncGetToString()
        msg = wait(8000, port)
        if type(msg) = "roUrlEvent" and msg.GetResponseCode() = 200
            json = ParseJson(msg.GetString())
            if json <> invalid and json.logos <> invalid and json.logos.Count() > 0
                best = invalid
                for each logo in json.logos
                    if logo.iso_639_1 = "en"
                        best = logo
                        exit for
                    end if
                end for
                if best = invalid then best = json.logos[0]
                logoUrl = "https://image.tmdb.org/t/p/w500" + best.file_path
            end if
        else if msg = invalid
            request.AsyncCancel()
        end if
    end if

    m.top.logoUrl = logoUrl
end sub
