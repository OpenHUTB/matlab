function clearFrames(this)





    if com.mathworks.toolbox.imaq.browser.IATBrowserDesktop.hasInstance()
        browser=iatbrowser.Browser();
        vidObj=browser.currentVideoinputObject;
        if isa(vidObj,'videoinput')&&isvalid(vidObj)
            flushdata(vidObj);
        end
    end

    this.data=[];

end