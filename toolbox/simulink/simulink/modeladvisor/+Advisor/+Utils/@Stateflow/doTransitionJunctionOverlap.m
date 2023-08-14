
function result=doTransitionJunctionOverlap(sfTransition,sfJunction)
    result=false;

    if isempty(sfTransition)||isempty(sfJunction)
        return;
    end




    if isa(sfTransition.Destination,'Stateflow.Junction')
        if isequal(sfTransition.Destination.Id,sfJunction.Id)
            return;
        end
    end


    if isa(sfTransition.Source,'Stateflow.Junction')
        if isequal(sfTransition.Source.Id,sfJunction.Id)
            return;
        end
    end

    if isempty(sfTransition.Source)
        spline=getSplineDefaultTransition(sfTransition);
    else
        spline=sfTransition.getSpline;
    end

    result=ModelAdvisor.internal.doSplineJunctionIntersect(spline,sfJunction);

end

function spline=getSplineDefaultTransition(transition)
    spline=[];
    if isempty(transition)||~isa(transition,'Stateflow.Transition')
        return;
    end

    spline=transition.getSpline;

    x=2*sign(spline(1,1)-spline(2,1));
    y=2*sign(spline(1,2)-spline(2,2));
    spline=[[spline(1,1)+x,spline(1,2)+y];spline];
end