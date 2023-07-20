function[c,ceq,dc,dceq]=mv_feasibilityTEconstraint(x,H,gT,gT0,...
    conScalingFactor)





















    y=x(1:end-1);

    z=x(end);


    c=conScalingFactor*(y'*H*y+2*gT'*y+gT0)-z;
    ceq=[];


    if nargout>2
        dc=[conScalingFactor*(2*H*y+2*gT);-1];
        dceq=[];
    end

end