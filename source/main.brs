sub Main()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    deviceInfo = CreateObject("roDeviceInfo")
    deviceInfo.SetMessagePort(m.port)
    deviceInfo.EnableLowGeneralMemoryEvent(true)

    m.appMemoryMonitor = CreateObject("roAppMemoryMonitor")
    m.appMemoryMonitor.SetMessagePort(m.port)
    m.appMemoryMonitor.EnableMemoryWarningEvent(true)

    channelMemoryLimit = m.appMemoryMonitor.GetChannelMemoryLimit()
    print "Channel memory limit (KB) - foreground: "; channelMemoryLimit.maxForegroundMemory; " background: "; channelMemoryLimit.maxBackgroundMemory; " Roku-managed heap: "; channelMemoryLimit.maxRokuManagedHeapMemory
    print "Channel available memory (KB): "; m.appMemoryMonitor.GetChannelAvailableMemory()

    globals = screen.getGlobalNode()
    globals.addFields({ navCollapsed: true })

    screen.CreateScene("MainScene")
    screen.show()

    while true
        msg = wait(0, m.port)
        if type(msg) = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        else if type(msg) = "roDeviceInfoEvent"
            if msg.isStatusMessage() and msg.GetInfo().generalMemoryLevel <> "normal"
                'Free caches, release unused ContentNodes, etc.
            end if
        else if type(msg) = "roAppMemoryNotificationEvent"
            'App memory usage crossed a warning threshold (80/85/90/95%); free caches, release unused ContentNodes, etc.
            print "App memory usage: "; m.appMemoryMonitor.GetMemoryLimitPercent(); "%"
        end if
    end while
end sub
