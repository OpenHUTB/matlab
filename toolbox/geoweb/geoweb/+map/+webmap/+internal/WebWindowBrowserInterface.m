classdef WebWindowBrowserInterface<map.webmap.internal.BrowserInterface





































    methods

        function hweb=web(browserIfc,url)
            channelID=browserIfc.ChannelID;
            ifc=map.webmap.internal.WebMapMessageInterface(channelID);
            browserIfc.WebMapMessageInterface=ifc;
            fcn=@()matlab.internal.webwindow(url);
            hweb=loadWebPage(ifc,fcn);
            show(hweb)
            browserIfc.Browser=hweb;
            makeActive(browserIfc)
        end


        function setCurrentLocation(browserIfc,url)
            if isValidBrowser(browserIfc)
                hweb=browserIfc.Browser;
                hweb.URL=url;
            end
        end


        function validBrowser=isValidBrowser(browserIfc)
            hweb=browserIfc.Browser;
            validBrowser=~isempty(hweb)&&hweb.isWindowValid;
        end


        function tf=isBrowserEnabled(browserIfc)
            tf=isValidBrowser(browserIfc)...
            &&~isempty(browserIfc.WebMapMessageInterface)...
            &&browserIfc.Browser.isWindowActive();
        end


        function makeActive(browserIfc)
            hweb=browserIfc.Browser;
            channelID=browserIfc.ChannelID;


            map.webmap.Canvas.saveActiveBrowserName(channelID);
            if~isempty(hweb)&&isvalid(hweb)&&hweb.isWindowValid...
                &&isprop(hweb,'FocusGained')
                fcn=@(src,evnt)map.webmap.Canvas.saveActiveBrowserName(channelID);
                hweb.FocusGained=fcn;
            end
        end

        function cdata=snapshot(browserIfc,~)


            cdata=getScreenshot(browserIfc.Browser);
        end

        function setCallback(browserIfc)
            hweb=browserIfc.Browser;
            hweb.CustomWindowClosingCallback=@(~,~)closeBrowser(browserIfc);
        end


        function close(browserIfc)
            if isBrowserEnabled(browserIfc)
                close(browserIfc.Browser)
            end
        end


        function setBrowserName(browserIfc,browserName)
            browserIfc.Browser.Title=browserName;
        end
    end

    methods(Hidden)
        function closeBrowser(browserIfc)






            if isBrowserEnabled(browserIfc)
                name=browserIfc.ChannelID;
                wm=getHandleFromAppdata(name);
                delete(wm)
            end
        end
    end
end


function wm=getHandleFromAppdata(name)


    if isappdata(0,'webmap')
        appdata=getappdata(0,'webmap');
        if~isempty(appdata)&&isvalid(appdata)&&isKey(appdata,name)
            wm=appdata(name);
            if~isvalid(wm)
                wm=[];
            end
        else
            wm=[];
        end
    else
        wm=[];
    end
end
