function Theme() as object
    if m._theme <> invalid then return m._theme

    tokens = m.global.designTokens
    if tokens = invalid then tokens = {}

    m._theme = {
        tokens: tokens,
        color: theme_value,
        size: theme_value,
        number: theme_value,
        font: theme_font
    }
    return m._theme
end function

function theme_value(name as string, fallback as dynamic) as dynamic
    value = m.tokens[LCase(name)]

    if value = invalid
        print "[theme] MISSING token: "; name
        return fallback
    end if

    return value
end function

function theme_font(name as string, fallback as string) as object
    spec = m.tokens[LCase(name)]

    if spec = invalid or type(spec) <> "roAssociativeArray"
        print "[theme] MISSING typography token: "; name
        return fallback
    end if

    uri = FontUri(spec.fontFamily)
    if uri = "" then return fallback

    font = CreateObject("roSGNode", "Font")
    font.uri = uri
    font.size = spec.fontSize
    return font
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
