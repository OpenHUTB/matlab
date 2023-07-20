function feedloc=calculateFeedLocation(obj)


    if isempty(obj.Tilt)||isempty(obj.TiltAxis)
        feedloc=[];
        return;
    end

    if isa(obj,'linearArray')
        feedloc=calculateLinearArrayFeedLocation(obj);
    elseif isa(obj,'rectangularArray')
        feedloc=calculateRectangularArrayFeedLocation(obj);
    elseif isa(obj,'circularArray')
        feedloc=calculateCircularArrayFeedLocation(obj);
    else
        feedloc=[];
        return;
    end
end