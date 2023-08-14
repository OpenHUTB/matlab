function doUpdate(hObj,updateState)















    if strcmp(hObj.ShowText,'on')




        addDependencyConsumed(hObj,{'ref_frame','xyzdatalimits'});
    end
    if~isnumeric(hObj.ZLocation_I)
        addDependencyConsumed(hObj,{'xyzdatalimits'});
    end

    updateContourZLevel(hObj,updateState);
    updateFill(hObj,updateState)
    labelPlacement=updateLines(hObj,updateState);
    updateLabels(hObj,updateState,labelPlacement)
    updateSelectionHandle(hObj)
end
