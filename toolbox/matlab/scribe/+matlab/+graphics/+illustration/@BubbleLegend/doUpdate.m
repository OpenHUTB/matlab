function doUpdate(hObj,updateState)



    markBubbleObjectsClean(hObj);


    syncPropertiesWithBubbleChart(hObj);




    if strcmp(hObj.Location,'none')
        updateTitleProperties(hObj);
        updateLimitLabelsProperties(hObj);


        if~isempty(hObj.SPosition)
            setLayoutPosition(hObj,hObj.SPosition);
            hObj.SPosition=[];
        end



        updateLegendPosition(hObj,updateState);

    end



    layoutBubbleLegendInternalObjects(hObj,updateState);


    if~isempty(hObj.SelectionHandle)&&hObj.Visible&&hObj.Selected&&hObj.SelectionHighlight
        hObj.SelectionHandle.Visible='on';
    elseif~isempty(hObj.SelectionHandle)
        hObj.SelectionHandle.Visible='off';
    end

end