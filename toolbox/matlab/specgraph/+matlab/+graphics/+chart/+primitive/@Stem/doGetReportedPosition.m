function pt=doGetReportedPosition(hObj,index,~)









    pt=doGetDisplayAnchorPoint(hObj,index,0);
    if isempty(hObj.ZDataCache)
        pt.Is2D=true;
    end
end

