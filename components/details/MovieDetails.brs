sub init()
    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")
    m.meta = m.top.findNode("meta")
    m.desc = m.top.findNode("desc")
end sub

sub onMovieContentChanged()
    movie = m.top.movieContent
    if movie = invalid then return

    m.poster.uri = movie.HDPosterUrl
    m.title.text = movie.title
    m.meta.text = "Rating: " + movie.rating + "    Released: " + movie.releaseDate
    m.desc.text = movie.description
end sub
