classdef(Abstract)BrowserInterface<handle





































    properties
        ChannelID='channelID'
    end

    properties(Access=protected)
Browser
WebMapMessageInterface
        PrintFlags={'-v','-bestfit'}
    end

    methods

        function browserIfc=BrowserInterface()


            browserIfc.Browser=[];
            browserIfc.WebMapMessageInterface=[];
        end

        function reset(browserIfc)


            browserIfc.Browser=[];
            browserIfc.WebMapMessageInterface=[];
        end

        function showBrowserSnapshotImage(browserIfc,hfig)



            set(hfig,'Visible','off')
            cdata=snapshot(browserIfc);
            set(hfig,'Visible','on')


            ax=get(hfig,'CurrentAxes');
            ax.Toolbar.Visible='off';
            matlab.graphics.interaction.disableDefaultAxesInteractions(ax)
            set(ax,'Units','normal','Position',[0,0,1,1])
            sizeF=size(cdata);
            set(hfig,'Position',[50,150,sizeF(2),sizeF(1)],...
            'MenuBar','none','Toolbar','none');


            image(cdata)
            axis image off
drawnow
shg
        end

        function print(browserIfc)





            useFrameSize=false;
            cdata=snapshot(browserIfc,useFrameSize);
            sizeF=size(cdata);



            pos=[1,1,sizeF(2),sizeF(1)];
            hfig=figure('Visible','off','Position',pos,...
            'MenuBar','none','Toolbar','none');


            cleanObj=onCleanup(@()close(hfig));


            ax=axes('Parent',hfig,'Visible','off','Color','white',...
            'Units','normalized','Position',[0,0,1,1],'YDir','reverse');
            ax.Toolbar.Visible='off';
            matlab.graphics.interaction.disableDefaultAxesInteractions(ax)


            image(cdata,'Parent',ax)
            ax.XAxis.Visible='off';
            ax.YAxis.Visible='off';




            if~isempty(cdata)
                print(hfig,browserIfc.PrintFlags{:})
            end
        end




        function setMapCenter(browserIfc,centerLat,centerLon,zoomLevel)









            if isBrowserEnabled(browserIfc)
                ifc=browserIfc.WebMapMessageInterface;
                if nargin<4
                    zoomLevel=getZoomLevel(browserIfc);
                end
                setMapCenter(ifc,centerLat,centerLon,zoomLevel)
            end
        end

        function[centerLat,centerLon]=getMapCenter(browserIfc)





            if isBrowserEnabled(browserIfc)
                ifc=browserIfc.WebMapMessageInterface;
                [centerLat,centerLon]=getMapCenter(ifc);
            else
                centerLat=0;
                centerLon=0;
            end
        end

        function setZoomLevel(browserIfc,zoomLevel)





            if isBrowserEnabled(browserIfc)
                ifc=browserIfc.WebMapMessageInterface;
                setZoomLevel(ifc,zoomLevel)
            end
        end

        function zoomLevel=getZoomLevel(browserIfc)





            if isBrowserEnabled(browserIfc)
                ifc=browserIfc.WebMapMessageInterface;
                zoomLevel=getZoomLevel(ifc);
            else
                zoomLevel=0;
            end
        end

        function setMapLimits(browserIfc,latlim,lonlim)





            if isBrowserEnabled(browserIfc)
                ifc=browserIfc.WebMapMessageInterface;
                setMapLimits(ifc,latlim,lonlim)
            end
        end

        function[latlim,lonlim]=getMapLimits(browserIfc)






            if isBrowserEnabled(browserIfc)
                ifc=browserIfc.WebMapMessageInterface;
                [latlim,lonlim]=getMapLimits(ifc);
            else
                latlim=[-90,90];
                lonlim=[-180,180];
            end
        end

        function addVectorOverlay(browserIfc,filename,overlayName)






            if isBrowserEnabled(browserIfc)
                ifc=browserIfc.WebMapMessageInterface;
                addVectorOverlay(ifc,filename,overlayName)
            end
        end

        function removeVectorOverlay(browserIfc,layerNumber)







            if isBrowserEnabled(browserIfc)
                ifc=browserIfc.WebMapMessageInterface;
                removeVectorOverlay(ifc,layerNumber)
            end
        end


    end

    methods(Abstract)

        hweb=web(browserIfc,url)

        setCurrentLocation(browserIfc,url)

        validBrowser=isValidBrowser(browserIfc)

        tf=isBrowserEnabled(browserIfc)

        makeActive(browserIfc)

        setCallback(browserIfc)

        close(browserIfc)

        setBrowserName(browserIfc,browserName)

        cdata=snapshot(browserIfc)

    end
end
