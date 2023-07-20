classdef ConnectorWebWindowBrowserInterface<map.webmap.internal.WebWindowBrowserInterface





































    methods
        function hweb=web(browserIfc,url)
            channelID=browserIfc.ChannelID;
            ifc=map.webmap.internal.WebMapMessageInterface(channelID);
            browserIfc.WebMapMessageInterface=ifc;
            fcn=@()loadAndShowURL(url);
            hweb=loadWebPage(ifc,fcn);
            browserIfc.Browser=hweb;
            browserIfc.PrintFlags={};
            makeActive(browserIfc)
        end

        function setCallback(browserIfc)
            hweb=browserIfc.Browser;
            hweb.MATLABWindowExitedCallback=@(~,~)closeBrowser(browserIfc);
            hweb.CustomWindowClosingCallback=@(~,~)closeBrowser(browserIfc);
        end
    end

    methods(Hidden)
        function closeBrowser(browserIfc)









            if~isempty(browserIfc)&&isvalid(browserIfc)
                name=browserIfc.ChannelID;
                wm=map.webmap.internal.getActiveWebMapCanvas(name);
                delete(wm)
            end
        end
    end
end

function hweb=loadAndShowURL(url)






    hweb=matlab.internal.webwindow(url);
    hweb.show()
end
