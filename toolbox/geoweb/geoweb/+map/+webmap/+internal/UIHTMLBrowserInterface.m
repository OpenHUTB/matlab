classdef UIHTMLBrowserInterface<map.webmap.internal.BrowserInterface





































    properties(Constant,Hidden)
        DefaultSize=[750,550]
    end

    properties(Access=?tUIHTMLBrowserInterface)




        Figure matlab.ui.Figure=matlab.ui.Figure.empty





        HTMLController matlab.ui.control.HTML=matlab.ui.control.HTML.empty
    end

    methods
        function hweb=web(browserIfc,url)







            channelID=browserIfc.ChannelID;
            ifc=map.webmap.internal.WebMapMessageInterface(channelID);
            browserIfc.WebMapMessageInterface=ifc;
            fcn=@()openWebmap(browserIfc,url);
            hweb=loadWebPage(ifc,fcn);
            browserIfc.Browser=hweb;
            makeActive(browserIfc)
        end


        function delete(browserIfc)





            deleteFigure(browserIfc)
        end


        function close(browserIfc)







            deleteFigure(browserIfc)
        end


        function makeActive(browserIfc)





            if~isempty(browserIfc)&&isvalid(browserIfc)
                channelID=browserIfc.ChannelID;
                map.webmap.Canvas.saveActiveBrowserName(channelID);
            end
        end


        function setBrowserName(browserIfc,browserName)





            hfig=browserIfc.Figure;
            if~isempty(hfig)&&isvalid(hfig)
                hfig.Name=browserName;
            end
        end


        function setCallback(browserIfc)%#ok<MANU>


        end


        function tf=isValidBrowser(browserIfc)





            if~isempty(browserIfc)&&isvalid(browserIfc)
                hfig=browserIfc.Figure;
                hweb=browserIfc.Browser;
                tf=~isempty(hfig)&&isvalid(hfig)&&...
                ~isempty(hweb)&&hweb.isWindowValid;
            else
                tf=false;
            end
        end


        function tf=isBrowserEnabled(browserIfc)






            tf=isValidBrowser(browserIfc)...
            &&~isempty(browserIfc.WebMapMessageInterface)...
            &&isvalid(browserIfc.WebMapMessageInterface)...
            &&browserIfc.Browser.isWindowActive();
        end


        function setCurrentLocation(browserIfc,url)





            if isValidBrowser(browserIfc)
                html=browserIfc.HTMLController;
                if~isempty(html)&&isvalid(html)
                    html.HTMLSource=url;
                end
            end
        end


        function cdata=snapshot(browserIfc,~)






            try
                hfig=browserIfc.Figure;
                cdata=matlab.ui.internal.FigureImageCaptureService.captureImage(hfig);
            catch
                cdata=zeros(255,255,3,'uint8');
            end
        end
    end

    methods(Hidden)
        function deleteFigure(browserIfc)





            if~isempty(browserIfc)
                hfig=browserIfc.Figure;
                if~isempty(hfig)&&isvalid(hfig)
                    hfig.DeleteFcn=[];
                    delete(hfig)
                end
            end
        end


        function closeBrowser(browserIfc)






            if~isempty(browserIfc)&&isvalid(browserIfc)
                name=browserIfc.ChannelID;
                wm=map.webmap.internal.getActiveWebMapCanvas(name);
                if~isempty(wm)&&isvalid(wm)


                    delete(wm)
                else


                    deleteFigure(browserIfc)
                end
            end
        end
    end

    methods(Access=private)
        function webwindow=openWebmap(browserIfc,url)















            pos=getCenterPosition(browserIfc.DefaultSize);
            uif=uifigure(...
            'Internal',true,...
            'Position',pos,...
            'Visible','off',...
            'AutoResizeChildren','off',...
            'ResizeFcn',@(src,~)resizeWebmap(browserIfc,src),...
            'CloseRequestFcn',@(~,~)closeBrowser(browserIfc),...
            'DeleteFcn',@(~,~)closeBrowser(browserIfc));
            browserIfc.Figure=uif;






            h=matlab.ui.control.HTML(...
            'Parent',uif,...
            'Position',[1,1,pos(3),pos(4)],...
            'HandleVisibility','off',...
            'Internal',true,...
            'HTMLSource',url);
            browserIfc.HTMLController=h;


            uif.Visible='on';


            figURL=matlab.ui.internal.FigureServices.getFigureURL(uif);



            wmgr=matlab.internal.webwindowmanager.instance;
            w=wmgr.windowList;
            webwindow=findobj(w,'URL',figURL);



            if isprop(webwindow,'FocusGained')
                channelID=browserIfc.ChannelID;
                fcn=@(src,evnt)map.webmap.Canvas.saveActiveBrowserName(channelID);
                webwindow.FocusGained=fcn;
            end
        end


        function resizeWebmap(browserIfc,src)



            pos=src.Position;
            html=browserIfc.HTMLController;
            html.Position=[1,1,pos(3),pos(4)];
        end
    end
end


function pos=getCenterPosition(windowSize)







    originalUnits=get(groot,"units");
    if~matches(originalUnits,"pixels")
        set(groot,"units","pixels");

        cleanObj=onCleanup(@()set(groot,"units",originalUnits));
    end


    screenSize=get(groot,'ScreenSize');
    posX=(screenSize(3)-windowSize(1))/2;
    posY=(screenSize(4)-windowSize(2))/2;
    pos=[posX,posY,windowSize];
end
