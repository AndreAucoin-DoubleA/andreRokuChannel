sub viewDidLoad(params as object)
end sub

sub viewWillAppear(params as object)
end sub

sub viewWillHide(params as object)
end sub

sub viewWillDisappear(params as object)
end sub

function setViewFocus() as boolean
    return m.top.setFocus(true)
end function

sub pushView(viewName as string, params as object)
    m.top.navRequest = { action: "push", view: viewName, params: params }
end sub
