function index=doGetNearestIndex(hObj,index)





    numPoints=numel(hObj.YDataCache);


    if numPoints>0
        index=max(1,min(index,numPoints));
    end
