function[c,ceq,dc,dceq]=mv_riskAndTrackingError_as_constraint(x,H,...
    g,g0,gT,gT0,riskStd,conScalingFactor)
























    c=conScalingFactor*([x'*H*x+2*g'*x+g0-riskStd*riskStd;...
    x'*H*x+2*gT'*x+gT0]);
    ceq=[];


    if nargout>2
        dc=conScalingFactor*[2*H*x+2*g,2*H*x+2*gT];
        dceq=[];
    end

end