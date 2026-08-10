function loadTokens(path as string) as object
    raw = ReadAsciiFile(path)
    if raw = ""
        print "[tokens] file missing or empty: "; path
        return {}
    end if

    tree = ParseJson(raw)
    if tree = invalid
        print "[tokens] malformed JSON: "; path
        return {}
    end if

    flat = {}
    FlattenTokens(tree, "", invalid, flat)
    return NormalizeTokens(ResolveAliases(flat))
end function

sub FlattenTokens(node as object, prefix as string, inheritedType as dynamic, flat as object)
    nodeType = inheritedType
    if node.DoesExist("$type") then nodeType = node["$type"]

    if node.DoesExist("$value")
        flat[LCase(prefix)] = { type: nodeType, value: node["$value"] }
    end if

    for each key in node
        if Left(key, 1) <> "$"
            child = node[key]
            if type(child) = "roAssociativeArray"
                childPrefix = key
                if prefix <> "" then childPrefix = prefix + "." + key
                FlattenTokens(child, childPrefix, nodeType, flat)
            end if
        end if
    end for
end sub

function ResolveAliases(flat as object) as object
    out = {}
    for each key in flat
        entry = flat[key]
        entryType = entry.type

        if entryType = invalid and IsAlias(entry.value)
            target = flat[AliasKey(entry.value)]
            if target <> invalid then entryType = target.type
        end if

        out[key] = { type: entryType, value: ResolveValue(entry.value, flat, 0) }
    end for
    return out
end function

function IsAlias(value as dynamic) as boolean
    if type(value) <> "roString" and type(value) <> "String" then return false
    return Left(value, 1) = "{" and Right(value, 1) = "}"
end function

function AliasKey(value as string) as string
    return LCase(Mid(value, 2, Len(value) - 2))
end function

function ResolveValue(value as dynamic, flat as object, depth as integer) as dynamic
    if depth > 10 then return value

    if type(value) = "roString" or type(value) = "String"
        if IsAlias(value)
            target = flat[AliasKey(value)]
            if target = invalid
                print "[tokens] unresolved alias: "; value
                return value
            end if
            return ResolveValue(target.value, flat, depth + 1)
        end if
        return value
    end if

    if type(value) = "roAssociativeArray"
        resolved = {}
        for each k in value
            resolved[k] = ResolveValue(value[k], flat, depth + 1)
        end for
        return resolved
    end if

    return value
end function

function NormalizeTokens(resolved as object) as object
    out = {}
    for each key in resolved
        entry = resolved[key]
        out[key] = { type: entry.type, value: NormalizeValue(entry.type, entry.value) }
    end for
    return out
end function

function NormalizeValue(tokenType as dynamic, value as dynamic) as dynamic
    if tokenType = "color" then return ColorToRgba(value)
    if tokenType = "dimension" then return DimensionToFloat(value)

    if tokenType = "typography"
        if type(value) = "roAssociativeArray"
            return {
                fontFamily: value.fontFamily,
                fontSize: DimensionToFloat(value.fontSize)
            }
        end if
    end if

    return value
end function

function DimensionToFloat(value as dynamic, scale = 1.0 as float) as float
    if value = invalid then return 0.0

    if type(value) = "roString" or type(value) = "String"
        s = LCase(value)
        s = s.Replace("px", "")
        s = s.Replace("rem", "")
        return Val(s.Trim()) * scale
    end if

    return value * scale
end function

function ColorToRgba(value as dynamic) as string
    badColor = "0xFF00FFFF"

    if type(value) <> "roString" and type(value) <> "String"
        print "[tokens] non-string color value"
        return badColor
    end if

    s = value
    if Left(s, 1) = "#" then s = Mid(s, 2)

    if Len(s) = 3
        s = Mid(s, 1, 1) + Mid(s, 1, 1) + Mid(s, 2, 1) + Mid(s, 2, 1) + Mid(s, 3, 1) + Mid(s, 3, 1)
    end if

    if Len(s) = 6 then s = s + "FF"

    if Len(s) <> 8
        print "[tokens] malformed color: "; value
        return badColor
    end if

    return "0x" + UCase(s)
end function
