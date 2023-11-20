function refreshHardwareList

    if com.mathworks.toolbox.imaq.browser.IATBrowserDesktop.hasInstance()
        mainFrame=iatbrowser.getDesktopFrame();
        browser=iatbrowser.Browser;
        if~isempty(mainFrame)

            browser.executeRefreshHardwareList();
        else

            browser.destroy();
        end
    end

end
