function getMovieConfig() as object
    return {
        apiKey: "488f756dc5932e8f8725809c68f6bf9d",
        baseUrl: "https://api.themoviedb.org/3"

    }
end function

function getMoviePaths(baseUrl as string, apiKey as string) as object
    return [
        { title: "Popular", path: baseUrl + "/movie/popular?api_key=" + apiKey + "&page=1" }
        { title: "Top Rated", path: baseUrl + "/movie/top_rated?api_key=" + apiKey + "&page=1" }
        { title: "Now Playing", path: baseUrl + "/movie/now_playing?api_key=" + apiKey + "&page=1" }
        { title: "Upcoming", path: baseUrl + "/movie/upcoming?api_key=" + apiKey + "&page=1" }
    ]
end function

function PageRegistry() as object
    return [
        { id: "home", label: "Home", icon: "pkg:/images/home_icon.png", component: "HomePage", type: "nav" }
        { id: "movies", label: "Movies", icon: "pkg:/images/settings_icon.png", component: "MoviesPage", type: "nav" }
        { id: "games", label: "Games", icon: "pkg:/images/menu_icon.png", component: "GamesPage", type: "nav" }
        { id: "details", component: "MovieDetails", type: "overlay" }
    ]
end function
