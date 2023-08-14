function resizeFigure(figureId,width,height,varargin)

    p=inputParser;
    p.addParameter('clientDpi',0);
    p.addParameter('overflowStrategy','border',@(arg)any(strcmpi(arg,{'border','stretch'})));

    p.parse(varargin{:});
    config=p.Results;

    hFig=mls.internal.handleID('toHandle',figureId);

    if ishghandle(hFig)&&width>0&&height>0

        desiredAspect=width/height;

        if config.clientDpi==0
            maxWidth=1280;
            maxHeight=1024;
        else
            screenSize=get(groot,'ScreenSize');
            maxWidth=screenSize(3);
            maxHeight=screenSize(4);
        end


        if config.clientDpi>0
            conversion=get(groot,'ScreenPixelsPerInch')/config.clientDpi;
            width=width*conversion;
            height=height*conversion;
        end

        newWidth=width;
        newHeight=height;

        overflowed=false;


        if width>maxWidth
            newWidth=maxWidth;
            height=newWidth/desiredAspect;
            overflowed=true;
        end


        if height>maxHeight
            newHeight=maxHeight;
            width=newHeight*desiredAspect;
            overflowed=true;
        end


        currUnits=get(hFig,'Units');
        pos=get(hFig,'Position');
        posPixels=hgconvertunits(hFig,pos,currUnits,'pixels',0);

        posPixels(2)=posPixels(2)-(newHeight-posPixels(4));
        posPixels(3)=newWidth;
        posPixels(4)=newHeight;

        newPos=hgconvertunits(hFig,posPixels,'pixels',currUnits,0);
        set(hFig,'Position',max([0,0,0,0],newPos));

        drawnow;



        actualPos=get(hFig,'Position');
        posPixels=hgconvertunits(hFig,actualPos,currUnits,'pixels',0);
        actualAspect=posPixels(3)/posPixels(4);
        if abs(actualAspect-desiredAspect)>2*eps(actualAspect)
            if actualAspect<desiredAspect

                posPixels(4)=posPixels(3)/desiredAspect;
            else

                posPixels(3)=posPixels(4)*desiredAspect;
            end
            newPos=hgconvertunits(hFig,posPixels,'pixels',currUnits,0);
            set(hFig,'Position',max([0,0,0,0],newPos));
            drawnow;
        end




        actualPos=get(hFig,'Position');
        posPixels=hgconvertunits(hFig,actualPos,currUnits,'pixels',0);
        actualAspect=posPixels(3)/posPixels(4);
        if abs(actualAspect-desiredAspect)>2*eps(actualAspect)
            if actualAspect>desiredAspect

                posPixels(4)=posPixels(3)/desiredAspect;
            else

                posPixels(3)=posPixels(4)*desiredAspect;
            end
            newPos=hgconvertunits(hFig,posPixels,'pixels',currUnits,0);
            set(hFig,'Position',max([0,0,0,0],newPos));
        end

        drawnow;


        children=findobj(hFig,'type','Axes');
        if numel(children)>0
            t=get(children(1),'Title');
            titleString=get(t,'String');
            set(t,'String','forceUpdate');
            set(t,'String',titleString);
        end

        drawnow;


        if strcmpi(config.overflowStrategy,'stretch')

            if width~=newWidth
                config.clientDpi=newWidth/width*config.clientDpi;
            elseif height~=newHeight
                config.clientDpi=newHeight/height*config.clientDpi;
            end
        end

        setappdata(hFig,'ClientDpi',config.clientDpi);

    end

end