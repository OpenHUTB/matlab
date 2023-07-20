function x=alternateGetframe(hFig,deviceRect,scaledRect,includeDecorations,varargin)


























    if~ishghandle(hFig,'figure')

        error(message('MATLAB:capturescreen:BadObject'));
    end
    if~matlab.ui.internal.isFigureShowEnabled&&matlab.ui.internal.isUIFigure(hFig)
        error(message('MATLAB:print:HeadlessFigureUnsupported'));
    end
    if~matlab.ui.internal.isFigureShowEnabled&&includeDecorations
        error(message('MATLAB:getframe:FigureWindowsMustBeEnabledForDecorations'));
    end
    if includeDecorations&&matlab.ui.internal.isUIFigure(hFig)

        matlab.ui.internal.UnsupportedInUifigure(hFig);
    end

    gfwdDoDrawnow=false;


    x.cdata=[];
    x.colormap=[];

    recheckRect=false;

    if includeDecorations||matlab.ui.internal.isUIFigure(hFig)||...
        (matlab.ui.internal.isFigureShowEnabled&&strcmp(hFig.Visible,'on'))
        x=matlab.graphics.internal.getframeWithDecorations(hFig,includeDecorations,gfwdDoDrawnow);
        recheckRect=true;
    else
        x.cdata=usePrintToGetframe(hFig);
    end

    if~isempty(deviceRect)
        rect=deviceRect;
        if recheckRect



            if includeDecorations
                figSize=hgconvertunits(hFig,hFig.OuterPosition,hFig.Units,'pixels',groot);
            else
                figSize=getpixelposition(hFig);
            end
            figSize=matlab.ui.internal.PositionUtils.getPixelRectangleInDevicePixels(figSize,hFig);

            figSize=round(figSize(3:4));
            imgSize=[size(x.cdata,2),size(x.cdata,1)];
            if~isequal(figSize,imgSize)

                rect=scaledRect;
            end
        end


        x.cdata=extractRect(x.cdata,rect);
    end


    if isempty(varargin)||length(varargin)<3
        return
    end


    isCallerGETFRAME=varargin{1};
    if~isempty(isCallerGETFRAME)&&isCallerGETFRAME
        originalH=varargin{2};
        isManualSize=varargin{3};
        [height,width,~]=size(x.cdata);
        matlab.graphics.internal.export.logDDUXInfo('getframe',originalH,width,height,isManualSize);
    end
end


function cdata=extractRect(cdata,offsetRect)


    offsetRect=fix(offsetRect);

    endY=size(cdata,1)-offsetRect(2)+1;
    startY=endY-offsetRect(4)+1;

    startX=offsetRect(1);
    endX=offsetRect(1)+offsetRect(3)-1;

    startX=max(startX,1);
    startY=max(startY,1);
    endX=min(endX,size(cdata,2));
    endY=min(endY,size(cdata,1));

    cdata=cdata(startY:endY,startX:endX,:);
end


function cdata=usePrintToGetframe(f)

    if~matlab.ui.internal.isFigureShowEnabled&&~isempty(validateFindControls(f))

        error(message('MATLAB:getframe:FigureWindowsMustBeEnabledForUIControls'));
    end

    pj=printjob(f);
    pj.Handles{1}=f;
    pj.ParentFig=ancestor(f,'figure');
    pj.DriverClass='IM';
    pj.RGBImage=1;
    pj.DPI=0;
    pj.doTransform=false;
    pj.CallerFunc='getframe';
    opts.fig=f;
    opts.props.PaperPosition=get(f,'PaperPosition');
    opts.props.PaperPositionMode=get(f,'PaperPositionMode');
    cleanupHandler=onCleanup(@()doCleanup(opts));
    set(f,'PaperPositionMode','auto');
    pj=alternatePrintPath(pj);
    cdata=pj.Return;
end

function doCleanup(opts)
    set(opts.fig,opts.props);
end
