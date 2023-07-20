function preRefreshHardwareList






    if com.mathworks.toolbox.imaq.browser.IATBrowserDesktop.hasInstance()
        browser=iatbrowser.Browser;
        browser.acqParamPanel.stopPropertyUpdateTimer();
    end

end
