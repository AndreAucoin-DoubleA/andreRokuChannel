sub init()
    m.stacks = {}
    m.activeStack = invalid
end sub


function showStack(id as string) as object
    entry = pageById(id)

    if entry = invalid then return invalid

    if m.activeStack <> invalid and m.top.activeStackId = id then return m.activeStack

    if m.activeStack <> invalid then m.activeStack.callFunc("suspendTop")

    container = m.top.stackContainer
    if container = invalid then return invalid

    stack = m.stacks[id]
    isNew = (stack = invalid)

    if isNew
        stack = container.createChild("ViewStack")
        stack.visible = false

        stack.observeField("stackDepth", "onStackDepthChanged")
        m.stacks[id] = stack

        stack.callFunc("setRoot", { view: entry.component, params: {}, inset: [160, 0] })
    end if

    for each key in m.stacks
        m.stacks[key].visible = (key = id)
    end for

    m.activeStack = stack
    m.top.activeStackId = id

    if not isNew then stack.callFunc("resumeTop")

    publishDepth()
    return stack
end function

function focusActive() as boolean
    if m.activeStack = invalid then return false
    return m.activeStack.callFunc("focusTop")
end function

function suspendActive() as boolean
    if m.activeStack = invalid then return false
    return m.activeStack.callFunc("suspendTop")
end function

function resumeActive() as boolean
    if m.activeStack = invalid then return false
    return m.activeStack.callFunc("resumeTop")
end function

sub onStackDepthChanged()
    publishDepth()
end sub

sub publishDepth()
    if m.activeStack = invalid
        m.top.activeDepth = 0
        return
    end if
    m.top.activeDepth = m.activeStack.callFunc("depth")
end sub
