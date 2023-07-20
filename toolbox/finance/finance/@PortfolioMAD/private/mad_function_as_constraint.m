function[ci,ceq,dci,dceq]=mad_function_as_constraint(x,Y,madlimit,...
    conScalingFactor)






















    if nargout<=2

        ci=mad_local_objective(x,Y);
        ci=ci-madlimit;
        ceq=[];

        if nargin==4
            ci=conScalingFactor*ci;
        end
    else

        [ci,dci]=mad_local_objective(x,Y);

        ci=ci-madlimit;
        ceq=[];
        dceq=[];

        if nargin==4
            ci=conScalingFactor*ci;
            dci=conScalingFactor*dci;
        end
    end



