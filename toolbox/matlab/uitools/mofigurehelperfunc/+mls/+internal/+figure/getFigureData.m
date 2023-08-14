function figureData=getFigureData(hFig,clientFigures,defaultFigureSize,...
    changeAspectRatio,dpi,skipImage,clientDpi,overflowStrategy,...
    method,thumbnailSize,imageFormat,imageQuality)
    if nargin<9
        method='print';
    end
    if nargin<10
        thumbnailSize=[];
    end
    if nargin<11
        imageFormat='png';
        imageQuality=1.0;
    end

    figureData.id=mls.internal.handleID('toID',hFig);
    figureData.title=get(hFig,'Name');

    if isempty(figureData.title)
        figureData.title=['Figure ',figureData.id];
    end

    timestamp=-1;
    for i=1:numel(clientFigures)
        if strcmp(clientFigures(i).id,figureData.id)&&...
            isfield(clientFigures(i),'timestamp')&&...
            numel(clientFigures(i).timestamp)>0
            timestamp=clientFigures(i).timestamp;
            break;
        end
    end

    if timestamp==-1&&numel(defaultFigureSize)==2


        pos=get(hFig,'Position');

        if changeAspectRatio
            newWidth=defaultFigureSize(1);
            newHeight=defaultFigureSize(2);
        else
            figAspect=pos(3)/pos(4);
            defaultAspect=defaultFigureSize(1)/defaultFigureSize(2);

            if figAspect>=defaultAspect
                newWidth=defaultFigureSize(1);
                newHeight=defaultFigureSize(1)/figAspect;
            else
                newWidth=defaultFigureSize(2)*figAspect;
                newHeight=defaultFigureSize(2);
            end
        end

        mls.internal.figure.resizeFigure(figureData.id,newWidth,newHeight,'clientDpi',clientDpi,'overflowStrategy',overflowStrategy);
    end



    currUnits=get(hFig,'Units');
    pos=get(hFig,'Position');
    posPixels=hgconvertunits(hFig,pos,currUnits,'Pixels',0);

    figureData.axes=mls.internal.figure.getAxesData(hFig);
    figureData.currentAxes=mls.internal.handleID('toID',get(hFig,'CurrentAxes'));

    if isappdata(hFig,'ClientDpi')
        figureData.imageDpi=getappdata(hFig,'ClientDpi');
    else
        figureData.imageDpi=clientDpi;
    end

    if figureData.imageDpi>0
        figureData.imageWidth=-1;
        figureData.imageHeight=-1;
    else
        figureData.imageWidth=posPixels(3);
        figureData.imageHeight=posPixels(4);
    end

    if~skipImage





        [isChanged,timestamp]=mls.internal.figure.figureChanged(hFig,timestamp);

        if isChanged
            [url,width,height]=mls.internal.figure.getFigureImageUrl(hFig,dpi,figureData.imageDpi,method,thumbnailSize,imageFormat,imageQuality);
            figureData.imageUrl=url;

            if figureData.imageDpi>0||~isempty(thumbnailSize)
                figureData.imageWidth=width;
                figureData.imageHeight=height;
            end


            [isChanged,timestamp]=mls.internal.figure.figureChanged(hFig,timestamp);
        else
            figureData.imageUrl='';
        end
    else
        figureData.imageUrl='';
    end
    figureData.timestamp=timestamp;
end
