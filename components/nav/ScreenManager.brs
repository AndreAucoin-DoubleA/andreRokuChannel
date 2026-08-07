sub init()
    m.stacks = {}
    m.activeStack = invalid
    m.modal = invalid
    m.modalParams = {}
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

function route(request as object) as object
    if request = invalid then return invalid

    stack = m.activeStack

    if request.stack <> invalid then stack = showStack(request.stack)
    if stack = invalid then return invalid
    if request.view = invalid then return stack

    return stack.callFunc("push", request)
end function

function presentModal(request as object) as object
    if request = invalid or request.view = invalid then return invalid

    container = m.top.modalContainer

    if container = invalid then return invalid
    if m.modal <> invalid then dismissModal()

    node = container.createChild(request.view)
    if node = invalid then return invalid

    if not node.IsSubtype("BaseView")
        print "[ScreenManager] " ; request.view ; " must extend BaseView"
        container.removeChild(node)
        return invalid
    end if

    params = request.params
    if params = invalid then params = {}

    m.modal = node
    m.modalParams = params

    node.callFunc("viewDidLoad", params)
    node.visible = true
    node.callFunc("viewWillAppear", params)
    return node
end function


function dismissModal() as boolean
    if m.modal = invalid then return false

    m.modal.callFunc("viewWillDisappear", m.modalParams)
    m.modal.visible = false

    container = m.top.modalContainer
    if container <> invalid then container.removeChild(m.modal)

    m.modal = invalid
    m.modalParams = {}

    focusActive()
    return true
end function

function activeView() as object
    if m.modal <> invalid then return m.modal
    if m.activeStack = invalid then return invalid
    return m.activeStack.callFunc("topNode")
end function

function focusActive() as boolean
    view = activeView()
    if view = invalid then return false
    return view.callFunc("setViewFocus")
end function

function suspendActive() as boolean
    if m.modal <> invalid
        m.modal.callFunc("viewWillHide", m.modalParams)
        return true
    end if
    if m.activeStack = invalid then return false
    return m.activeStack.callFunc("suspendTop")
end function

function resumeActive() as boolean
    if m.modal <> invalid
        m.modal.callFunc("viewWillAppear", m.modalParams)
        m.modal.callFunc("setViewFocus")
        return true
    end if
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
