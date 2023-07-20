function result=isTransitionInsideBox(transition,box)
    result=false;
    if isempty(transition)||isempty(box)
        return;
    end

    spline=transition.getSpline;
    xMin=box.Position(1);yMin=box.Position(2);
    xMax=xMin+box.Position(3);yMax=yMin+box.Position(4);

    for n=1:length(spline)
        if spline(n,1)<xMin||spline(n,1)>xMax||...
            spline(n,2)<yMin||spline(n,2)>yMax
            return;
        end
    end

    result=true;
end