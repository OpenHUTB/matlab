function[ci,ceq,dci,dceq]=cvar_function_as_constraint(x,Y,plevel,...
    cvarlimit,conScalingFactor)























    if nargout<=2

        ci=cvar_function_as_objective(x,Y,plevel);
        ci=ci-cvarlimit;
        ceq=[];

        if nargin==5
            ci=conScalingFactor*ci;
        end
    else

        [ci,dci]=cvar_function_as_objective(x,Y,plevel);

        ci=ci-cvarlimit;
        ceq=[];
        dceq=[];

        if nargin==5
            ci=conScalingFactor*ci;
            dci=conScalingFactor*dci;
        end
    end

