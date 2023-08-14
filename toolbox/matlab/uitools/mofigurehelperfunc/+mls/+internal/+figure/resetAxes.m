function resetAxes(axesId)

    hAxes=mls.internal.handleID('toHandle',axesId);

    if ishghandle(hAxes)

        hAxes=mls.internal.figure.vectorizeAxes(hAxes);

        resetplotview(hAxes,'ApplyStoredView');
    end

end

