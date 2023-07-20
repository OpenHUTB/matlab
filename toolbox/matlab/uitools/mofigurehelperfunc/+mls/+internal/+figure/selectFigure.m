function selectFigure(figureId)

    hFig=mls.internal.handleID('toHandle',figureId);

    if ishghandle(hFig)
        figure(hFig);
    end

end
