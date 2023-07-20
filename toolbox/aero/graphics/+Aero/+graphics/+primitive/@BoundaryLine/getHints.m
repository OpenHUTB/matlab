function hints=getHints(hObj)







    p=hObj.MarkerSize;

    paddingHints={{'PointPaddedX',p},{'PointPaddedY',p},{'PointPaddedZ',0}};

    hints=paddingHints;

end

