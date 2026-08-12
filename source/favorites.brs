' Favorited movie IDs, persisted in the channel registry.
'
' A movieId is a favorite if a key with that name exists in the "favorites"
' section; the stored value is unused. Registry writes go to flash, so
' Flush() is only called when something actually changed - see
' onFavoriteToggled in MovieDetails.brs, which drops redundant writes.

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
        section.Write(movieId, "1")
    else
        section.Delete(movieId)
    end if

    section.Flush()
end sub
