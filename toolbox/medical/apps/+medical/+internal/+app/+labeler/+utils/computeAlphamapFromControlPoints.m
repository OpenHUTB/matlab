function amap=computeAlphamapFromControlPoints(controlPoints,volumeBounds)




    volumeBounds=double(volumeBounds);

    intensityValues=controlPoints(:,1);
    alphaValues=controlPoints(:,2);

    if volumeBounds(1)~=volumeBounds(2)
        queryPoints=volumeBounds(1):volumeBounds(2);
    else
        queryPoints=intensityValues(1):intensityValues(end);
    end

    amap=interp1(intensityValues,alphaValues,queryPoints)';

    if isnan(amap(1))
        firstNonNanIdx=find(~isnan(amap),1);
        amap(1:firstNonNanIdx-1)=amap(firstNonNanIdx);
    end

    if isnan(amap(end))
        lastNonNanIdx=find(~isnan(amap),1,'last');
        amap(lastNonNanIdx:end)=amap(lastNonNanIdx);
    end



    queryPoints=round(linspace(1,length(amap),256));
    amap=amap(queryPoints);

end
