function favoritesSection() as object
    return CreateObject("roRegistrySection", "favorites")
end function

function isFavorite(movieId as dynamic) as boolean
    if movieId = invalid or movieId = "" then return false

    return favoritesSection().Exists(movieId)
end function

sub setFavorite(movieId as dynamic, favorited as boolean)
    if movieId = invalid or movieId = "" then return

    section = favoritesSection()

    if favorited
        section.Write(movieId, CreateObject("roDateTime").AsSeconds().ToStr())
    else
        section.Delete(movieId)
    end if

    section.Flush()

    m.global.favoritesVersion = m.global.favoritesVersion + 1

    trackEvent("favorite_toggled", {
        movieId: movieId,
        favorited: favorited,
        totalFavorites: section.GetKeyList().Count()
    })
end sub

function favoriteIds() as object
    section = favoritesSection()
    entries = []

    for each movieId in section.GetKeyList()
        entries.Push({ movieId: movieId, addedAt: section.Read(movieId).ToInt() })
    end for

    entries.SortBy("addedAt", "r")

    ids = []

    for each entry in entries
        ids.Push(entry.movieId)
    end for

    return ids
end function
