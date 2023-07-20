function[ci,ce,dci,dce]=mv_risk_as_constraint(z,risk,H,g,g0,...
    conScalingFactor)



























    ci=g0+2*g'*z+z'*H*z-risk*risk;
    ce=[];

    if nargin==6
        ci=conScalingFactor*ci;
    end

    if nargout>2
        dci=2*(g+H*z);
        dce=[];

        if nargin==6
            dci=conScalingFactor*dci;
        end
    end

end
