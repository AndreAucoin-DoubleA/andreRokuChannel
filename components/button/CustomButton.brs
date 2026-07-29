sub init()
    m.customButton = m.top.findNode("customButton")
    m.label = m.top.findNode("label")
    m.top.observeField("focusedChild", "onFocusChanged")
end sub

sub onTextChanged()
    m.label.text = m.top.text
end sub

sub onWidthChanged()
    if m.label = invalid then return
    m.customButton.width = m.top.width
    m.label.width = m.top.width
end sub

sub onFocusChanged()
    if m.top.hasFocus()
        m.customButton.color = "#4444aa"
        m.label.color = "#FFFFFF"
    else
        m.customButton.color = "#1b1b3a"
        m.label.color = "#AAAACC"
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press and key = "OK"
        m.top.selected = true
        return true
    end if
    return false
end function
