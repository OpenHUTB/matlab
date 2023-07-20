function[ci,ce,dci,dce]=mv_tracking_error_as_constraint(z,H,g,g0,...
    conScalingFactor)


























    ci=g0+2*g'*z+z'*H*z;
    ce=[];

    if nargin==5
        ci=conScalingFactor*ci;
    end

    if nargout>2
        dci=2*(g+H*z);
        dce=[];

        if nargin==5
            dci=conScalingFactor*dci;
        end
    end
