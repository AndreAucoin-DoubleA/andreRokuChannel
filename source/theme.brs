function Theme(refresh = false as boolean) as object
    if m._theme <> invalid and not refresh then return m._theme

    tokens = m.global.designTokens
    if tokens = invalid then tokens = {}

    m._theme = {
        tokens: tokens,
        fontCache: {},
        color: theme_color,
        size: theme_size,
        number: theme_number,
        font: theme_font
    }
    return m._theme
end function

function theme_color(name as string, fallback as string) as string
    entry = m.tokens[LCase(name)]
    if entry = invalid
        print "[theme] MISSING color token: "; name
        return fallback
    end if
    return entry.value
end function

function theme_size(name as string, fallback as float) as float
    entry = m.tokens[LCase(name)]
    if entry = invalid
        print "[theme] MISSING size token: "; name
        return fallback
    end if
    return entry.value
end function

function theme_number(name as string, fallback as float) as float
    entry = m.tokens[LCase(name)]
    if entry = invalid
        print "[theme] MISSING number token: "; name
        return fallback
    end if
    return entry.value
end function

function theme_font(name as string, fallback as string) as object
    entry = m.tokens[LCase(name)]
    if entry = invalid or type(entry.value) <> "roAssociativeArray"
        print "[theme] MISSING typography token: "; name
        return fallback
    end if

    spec = entry.value
    key = LCase(spec.fontFamily) + "@" + Str(spec.fontSize)
    if m.fontCache[key] <> invalid then return m.fontCache[key]

    uri = FontUri(spec.fontFamily)
    if uri = "" then return fallback

    f = CreateObject("roSGNode", "Font")
    f.uri = uri
    f.size = spec.fontSize

    m.fontCache[key] = f
    return f
end function

function FontUri(family as string) as string
    registry = {
        ' "inter regular": "pkg:/fonts/Inter-Regular.ttf",
        ' "inter bold":    "pkg:/fonts/Inter-Bold.ttf"
    }

    uri = registry[LCase(family)]
    if uri = invalid
        print "[theme] no font asset shipped for family: "; family; " (using system font)"
        return ""
    end if
    return uri
end function

function AppAssets() as object
    return {
        backgroundUri: "pkg:/images/app_background_fhd.jpg"
    }
end function
