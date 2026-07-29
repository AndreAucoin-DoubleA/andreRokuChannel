function getMovieConfig() as object
    return {
        apiKey: "488f756dc5932e8f8725809c68f6bf9d",
        baseUrl: "https://api.themoviedb.org/3"

    }
end function



function getMoviePaths(baseUrl as string, apiKey as string) as object
    return [
        { title: "Movie - Popular", path: baseUrl + "/movie/popular?api_key=" + apiKey + "&page=1" }
        { title: "Movie - Top Rated", path: baseUrl + "/movie/top_rated?api_key=" + apiKey + "&page=1" }
        { title: "Movie - Now Playing", path: baseUrl + "/movie/now_playing?api_key=" + apiKey + "&page=1" }
        { title: "Movie - Upcoming", path: baseUrl + "/movie/upcoming?api_key=" + apiKey + "&page=1" }
        { title: "Movie - Action", path: baseUrl + "/discover/movie?with_genres=28&api_key=" + apiKey + "&page=1" },
        { title: "Movie - Adventure", path: baseUrl + "/discover/movie?with_genres=12&api_key=" + apiKey + "&page=1" },
        { title: "Movie - Animation", path: baseUrl + "/discover/movie?with_genres=16&api_key=" + apiKey + "&page=1" },
        { title: "Movie - Comedy", path: baseUrl + "/discover/movie?with_genres=35&api_key=" + apiKey + "&page=1" },
        { title: "Movie - Crime", path: baseUrl + "/discover/movie?with_genres=80&api_key=" + apiKey + "&page=1" },
        { title: "Movie - Documentary", path: baseUrl + "/discover/movie?with_genres=99&api_key=" + apiKey + "&page=1" },
        { title: "Movie - Drama", path: baseUrl + "/discover/movie?with_genres=18&api_key=" + apiKey + "&page=1" },
        { title: "Movie - Family", path: baseUrl + "/discover/movie?with_genres=10751&api_key=" + apiKey + "&page=1" },
        { title: "Movie - Fantasy", path: baseUrl + "/discover/movie?with_genres=14&api_key=" + apiKey + "&page=1" },
        { title: "Movie - History", path: baseUrl + "/discover/movie?with_genres=36&api_key=" + apiKey + "&page=1" },
        { title: "Movie - Horror", path: baseUrl + "/discover/movie?with_genres=27&api_key=" + apiKey + "&page=1" },
        { title: "Movie - Music", path: baseUrl + "/discover/movie?with_genres=10402&api_key=" + apiKey + "&page=1" },
        { title: "Movie - Mystery", path: baseUrl + "/discover/movie?with_genres=9648&api_key=" + apiKey + "&page=1" },
        { title: "Movie - Romance", path: baseUrl + "/discover/movie?with_genres=10749&api_key=" + apiKey + "&page=1" },
        { title: "Movie - Science Fiction", path: baseUrl + "/discover/movie?with_genres=878&api_key=" + apiKey + "&page=1" },
        { title: "Movie - TV Movie", path: baseUrl + "/discover/movie?with_genres=10770&api_key=" + apiKey + "&page=1" },
        { title: "Movie - Thriller", path: baseUrl + "/discover/movie?with_genres=53&api_key=" + apiKey + "&page=1" },
        { title: "Movie - War", path: baseUrl + "/discover/movie?with_genres=10752&api_key=" + apiKey + "&page=1" },
        { title: "Movie - Western", path: baseUrl + "/discover/movie?with_genres=37&api_key=" + apiKey + "&page=1" },
        { title: "TV - Action & Adventure", path: baseUrl + "/discover/tv?with_genres=10759&api_key=" + apiKey + "&page=1" },
        { title: "TV - Animation", path: baseUrl + "/discover/tv?with_genres=16&api_key=" + apiKey + "&page=1" },
        { title: "TV - Comedy", path: baseUrl + "/discover/tv?with_genres=35&api_key=" + apiKey + "&page=1" },
        { title: "TV - Crime", path: baseUrl + "/discover/tv?with_genres=80&api_key=" + apiKey + "&page=1" },
        { title: "TV - Documentary", path: baseUrl + "/discover/tv?with_genres=99&api_key=" + apiKey + "&page=1" },
        { title: "TV - Drama", path: baseUrl + "/discover/tv?with_genres=18&api_key=" + apiKey + "&page=1" },
        { title: "TV - Family", path: baseUrl + "/discover/tv?with_genres=10751&api_key=" + apiKey + "&page=1" },
        { title: "TV - Kids", path: baseUrl + "/discover/tv?with_genres=10762&api_key=" + apiKey + "&page=1" },
        { title: "TV - Mystery", path: baseUrl + "/discover/tv?with_genres=9648&api_key=" + apiKey + "&page=1" },
        { title: "TV - News", path: baseUrl + "/discover/tv?with_genres=10763&api_key=" + apiKey + "&page=1" },
        { title: "TV - Reality", path: baseUrl + "/discover/tv?with_genres=10764&api_key=" + apiKey + "&page=1" },
        { title: "TV - Sci-Fi & Fantasy", path: baseUrl + "/discover/tv?with_genres=10765&api_key=" + apiKey + "&page=1" },
        { title: "TV - Soap", path: baseUrl + "/discover/tv?with_genres=10766&api_key=" + apiKey + "&page=1" },
        { title: "TV - War & Politics", path: baseUrl + "/discover/tv?with_genres=10768&api_key=" + apiKey + "&page=1" },
        { title: "TV - Talk", path: baseUrl + "/discover/tv?with_genres=10767&api_key=" + apiKey + "&page=1" },
        { title: "TV - Western", path: baseUrl + "/discover/tv?with_genres=37&api_key=" + apiKey + "&page=1" },
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
