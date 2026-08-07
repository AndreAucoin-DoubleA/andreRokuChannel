sub init()
    m.stack = []
end sub

function depth() as integer
    return m.stack.Count()
end function

function peek() as object
    if depth() = 0 then return invalid
    return m.stack[depth() - 1]
end function

function pop() as boolean
    if depth() <= 1 then return false

    destroyTop()
    revealTop()
    publishDepth()
    return true
end function

function topNode() as object
    entry = peek()
    if entry = invalid then return invalid
    return entry.node
end function

function focusTop() as boolean
    entry = peek()
    if entry = invalid then return false
    return entry.node.callFunc("setViewFocus")
end function

sub destroyTop()
    entry = m.stack.Pop()

    if entry = invalid then return

    entry.node.callFunc("viewWillDisappear", entry.params)
    entry.node.unobserveField("navRequest")
    entry.node.visible = false
    m.top.removeChild(entry.node)
end sub


function setRoot(request as object) as object
    while depth() > 0
        destroyTop()
    end while

    node = pushEntry(request)

    publishDepth()

    return node

end function

sub revealTop()
    entry = peek()

    if entry = invalid then return

    entry.node.visible = true
    resumeTop()
end sub

sub publishDepth()
    m.top.stackDepth = depth()
end sub


function resumeTop() as boolean
    entry = peek()
    if entry = invalid then return false

    entry.node.callFunc("viewWillAppear", entry.params)
    entry.node.callFunc("setViewFocus")
    return true
end function

sub onNavRequest(msg as object)
    req = msg.GetData()

    if req = invalid or req.action = invalid then return

    if req.action = "push" then push(req)
    if req.action = "pop" then pop()
    if req.action = "popToRoot" then popToRoot()
end sub

function popToRoot() as boolean
    if depth() <= 1 then return false

    while depth() > 1
        destroyTop()
    end while

    revealTop()

    publishDepth()

    return true
end function

function suspendTop() as boolean
    entry = peek()

    if entry = invalid then return false

    entry.node.callFunc("viewWillHide", entry.params)

    return true
end function

function pushEntry(request as object) as object
    if request = invalid or request.view = invalid then return invalid

    node = m.top.createChild(request.view)

    if not node.isSubtype("BaseView")
        print "[ViewStack] " ; request.view ; " must extend BaseView"
        m.top.removeChild(node)
        return invalid
    end if

    params = request.params

    if params = invalid then params = {}

    if request.inset <> invalid then node.translation = request.inset

    m.stack.Push({ name: request.view, node: node, params: params })
    node.observeField("navRequest", "onNavRequest")

    node.callFunc("viewDidLoad", params)
    node.visible = true

    node.callFunc("viewWillAppear", params)
    node.callFunc("setViewFocus")

    return node
end function

function push(request as object) as object
    if depth() >= m.top.maxDepth
        print "[ViewStack] push rejected: maxDepth " ; m.top.maxDepth ; " reached"
        return invalid
    end if

    current = peek()

    if current <> invalid
        current.node.callFunc("viewWillHide", current.params)
        current.node.visible = false
    end if

    node = pushEntry(request)
    publishDepth()

    return node
end function

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false
    if key = "back" then return pop()
    return false
end function


