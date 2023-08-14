function stopPreview(this,vidObj,clearWindow)





    assert(exist('vidObj','var')==1,'vidObj undefined');

    this.previewing=false;

    if~isempty(vidObj)&&isvalid(vidObj)
        stoppreview(vidObj);



        if com.mathworks.toolbox.imaq.browser.IATBrowserDesktop.hasInstance()
            ed=iatbrowser.SessionLogEventData(vidObj,'stoppreview(vid);\n\n');
            iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);
        end

        if clearWindow
            this.clearWindow('iatbrowser.FormatNode',iatbrowser.getResourceString('RES_DESKTOP','PreviewPanel.HelpMessage'));
        end
    end

end