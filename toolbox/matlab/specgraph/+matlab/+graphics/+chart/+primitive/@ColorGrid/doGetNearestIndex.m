function index=doGetNearestIndex(hObj,index)




    numPoints=numel(hObj.ColorData);
    index=max(1,min(numPoints,index));

end
