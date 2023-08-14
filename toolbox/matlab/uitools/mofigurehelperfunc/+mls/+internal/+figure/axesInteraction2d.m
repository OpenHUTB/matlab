function axesInteraction2d(axesId,origin,endPt)

    hAxes=mls.internal.handleID('toHandle',axesId);

    if ishghandle(hAxes)

        hAxes=mls.internal.figure.vectorizeAxes(hAxes);


        resetplotview(hAxes,'InitializeCurrentView');

        [currentXLim,currentYLim]=getCurrentLimits(hAxes);
        [newXLim,newYLim]=getNewAxesLimits(hAxes,currentXLim,currentYLim,origin,endPt);
        mls.internal.figure.doZoom2d(hAxes,currentXLim,currentYLim,newXLim,newYLim);
    end

end


function[currentXLim,currentYLim]=getCurrentLimits(hAxes)


    currentXLim=ruler2num(get(hAxes,'XLim'),get(hAxes,'XAxis'));
    currentYLim=ruler2num(get(hAxes,'YLim'),get(hAxes,'YAxis'));
    if~iscell(currentXLim)
        currentXLim={currentXLim};
        currentYLim={currentYLim};
    end

end


function[newXLim,newYLim]=getNewAxesLimits(hAxes,currentXLim,currentYLim,origin,endPt)

    newXLim=cell(size(currentXLim));
    newYLim=cell(size(currentYLim));

    for k=1:length(hAxes),
        cAx=hAxes(k);

        [newXLim{k},newYLim{k}]=mls.internal.figure.getNewAxesLimits(cAx,origin,endPt);
    end

end
