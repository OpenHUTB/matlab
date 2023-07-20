function doUpdate(hObj,~)










    if isempty(hObj.Parent)||isempty(hObj.PointDataTip)
        return;
    end




    if strcmpi(hObj.XMode,'manual')||...
        strcmpi(hObj.YMode,'manual')||...
        strcmpi(hObj.ZMode,'manual')
        hObj.moveDataTip();
    elseif strcmpi(hObj.SnapToDataVertex,'off')&&strcmpi(hObj.InterpolationFactorMode,'manual')


        hObj.recalculateDataIndex();
    end
end