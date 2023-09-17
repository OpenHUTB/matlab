classdef ExternalBrowserInterface<map.webmap.internal.BrowserInterface

    methods

        function hweb=web(browserIfc,url)
            channelID=browserIfc.ChannelID;
            ifc=map.webmap.internal.WebMapMessageInterface(channelID);
            browserIfc.WebMapMessageInterface=ifc;
            fcn=@()openWeb(url);
            hweb=loadWebPage(ifc,fcn);
            browserIfc.Browser=hweb;
        end


        function setCurrentLocation(browserIfc,url)
            if isValidBrowser(browserIfc)
                web(url,'-browser');
            end
        end


        function validBrowser=isValidBrowser(browserIfc)
            hweb=browserIfc.Browser;
            validBrowser=isempty(hweb);
        end

        function tf=isBrowserEnabled(browserIfc)


            tf=~isempty(browserIfc.WebMapMessageInterface);
        end

        function makeActive(~)
        end

        function close(~)
        end

        function setCallback(~)
        end

        function setBrowserName(~,~)
        end

        function cdata=snapshot(~,~)
            cdata=ones(255,255,'uint8');
        end
    end
end

function hweb=openWeb(url)
    web(url,'-browser');
    hweb=[];
end
