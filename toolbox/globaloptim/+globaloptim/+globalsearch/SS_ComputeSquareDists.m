function DistanceList=SS_ComputeSquareDists(FromSet,FromSetLength,ToSet,ToSetLength)





















    DistanceList=Inf(ToSetLength,1);
    for ToSetCounter=1:ToSetLength
        DistanceList(ToSetCounter)=min(sum((FromSet(1:FromSetLength,:)-ones(FromSetLength,1)*ToSet(ToSetCounter,:)).^2,2));
    end