function varargout=doGetNearestIndex(hObj,index)








    if hObj.UpdateGroupStats
        computeGroupStatistics(hObj)
        hObj.UpdateGroupStats=false;
    end

    numIndices=hObj.XNumGroups+sum(hObj.GroupStatistics.NumOutliers);


    if numIndices>0
        index=max(1,min(index,numIndices));
    end
    varargout{1}=index;
end