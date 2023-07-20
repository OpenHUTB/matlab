function new_lims=panFromPointToPoint3D(orig_limits,orig_point,curr_point)

    delta=iFindPerpendicular(curr_point,orig_point);
    new_lims=matlab.graphics.interaction.internal.pan.calculatePannedLimits(orig_limits,delta);

    function v=iFindPerpendicular(p1,p2)

        denom=(p2(2,:)-p2(1,:))*((p1(2,:)-p1(1,:))');
        if abs(denom)<eps(denom)
            lambda=0;
        else
            lambda=(p1(1,:)-p2(1,:))*((p1(2,:)-p1(1,:))')/denom;
        end
        v=(p2(1,:)-p1(1,:))+(p2(2,:)-p2(1,:))*lambda;

