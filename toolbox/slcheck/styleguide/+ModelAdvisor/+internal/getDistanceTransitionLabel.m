


function distance=getDistanceTransitionLabel(transition,labelPosition)
    distance=-1;

    if isempty(transition)||isempty(labelPosition)
        return;
    end

    labelCenterX=labelPosition(1)+labelPosition(3)/2;
    labelCenterY=labelPosition(2)+labelPosition(4)/2;

    spline=transition.getSpline;
    numPointsArrow=4;
    spline=spline(1:size(spline,1)-numPointsArrow,:);




    distance=realmax;
    for n=1:length(spline)
        distance=min(distance,sqrt((labelCenterX-spline(n,1))^2+...
        (labelCenterY-spline(n,2))^2));
    end

    distance=distance/size(spline,1);
end