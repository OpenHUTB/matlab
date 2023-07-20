function result=isTransitionStraight(transition)
    result=true;
    if isempty(transition)
        return;
    end

    spline=transition.getSpline;
    if size(spline)<2
        return;
    end


    numArrowPoints=4;


    dy=(spline(2,2)-spline(1,2));
    dx=(spline(2,1)-spline(1,1));
    slope=dy/dx;

    for idx=2:length(spline)-numArrowPoints-1
        dy=(spline(idx+1,2)-spline(idx,2));
        dx=(spline(idx+1,1)-spline(idx,1));
        newSlope=dy/dx;

        if round(slope,2)~=round(newSlope,2)
            result=false;
            return;
        end
    end
end