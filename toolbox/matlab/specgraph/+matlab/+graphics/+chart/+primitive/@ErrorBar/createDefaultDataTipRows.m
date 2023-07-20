function dataTipRows=createDefaultDataTipRows(hObj)






    xRow=dataTipTextRow('X','XData');
    yRow=dataTipTextRow('Y','YData');



    xDeltaRow=[];
    if~isempty(hObj.XNegativeDelta_I)||~isempty(hObj.XPositiveDelta_I)
        xDeltaRow=dataTipTextRow('X Delta','X Delta');
    end



    yDeltaRow=[];
    if~isempty(hObj.YNegativeDelta_I)||~isempty(hObj.YPositiveDelta_I)
        yDeltaRow=dataTipTextRow('Y Delta','Y Delta');
    end

    dataTipRows=[xRow;yRow;xDeltaRow;yDeltaRow];
end