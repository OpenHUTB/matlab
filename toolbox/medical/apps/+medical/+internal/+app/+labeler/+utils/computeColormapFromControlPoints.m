function cmap=computeColormapFromControlPoints(controlPoints,volumeBounds)




    volumeBounds=double(volumeBounds);

    intensityValues=controlPoints(:,1);
    colorValues=controlPoints(:,2:end);

    if volumeBounds(1)~=volumeBounds(2)
        queryPoints=volumeBounds(1):volumeBounds(2);
    else
        queryPoints=intensityValues(1):intensityValues(end);
    end

    cmap=interp1(intensityValues,colorValues,queryPoints);

    if isnan(cmap(1,1))
        firstNonNanIdx=find(~isnan(cmap(:,1)),1);
        cmap(1:firstNonNanIdx-1,:)=repmat(cmap(firstNonNanIdx,:),firstNonNanIdx-1,1);
    end

    if isnan(cmap(end,1))
        lastNonNanIdx=find(~isnan(cmap(:,1)),1,'last');

        lastIdx=size(cmap,1);
        cmap(lastNonNanIdx:lastIdx,:)=repmat(cmap(lastNonNanIdx,:),lastIdx-lastNonNanIdx+1,1);
    end


    queryPoints=round(linspace(1,size(cmap,1),256));
    cmap=cmap(queryPoints,:);

end
