function[c,ceq,dc,dceq]=mv_feasibilityRiskAndTEconstraint(x,H,g,...
    g0,gT,gT0,riskStd,conScalingFactor)

























    y=x(1:end-1);

    z=x(end);


    c=[conScalingFactor*(y'*H*y+2*g'*y+g0-riskStd^2)-z;...
    conScalingFactor*(y'*H*y+2*gT'*y+gT0)-z];
    ceq=[];



    if nargout>2
        dc=[conScalingFactor*[2*H*y+2*g,2*H*y+2*gT];...
        [-1,-1]];
        dceq=[];
    end

end