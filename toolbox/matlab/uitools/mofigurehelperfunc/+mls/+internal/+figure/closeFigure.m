function closeFigure(figureId)

    hFig=mls.internal.handleID('toHandle',figureId);

    if ishghandle(hFig)
        close(hFig);
    end

end

