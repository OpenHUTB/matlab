function pt=doGetReportedPosition(hObj,index,~)

    pt=doGetDisplayAnchorPoint(hObj,index,0);
    pt.Is2D=true;
end

