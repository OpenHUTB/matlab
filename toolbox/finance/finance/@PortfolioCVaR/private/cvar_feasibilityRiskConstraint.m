function[ci,ceq,dci,dceq]=cvar_feasibilityRiskConstraint(x,Y,plevel,...
    brisk,conScalingFactor)





















    xOriginal=x(1:end-1);

    z=x(end);


    if nargout<=2

        ci=cvar_function_as_constraint(xOriginal,Y,plevel,brisk);

        ci=conScalingFactor*ci-z;
        ceq=[];
    else

        [ci,~,dci,~]=cvar_function_as_constraint(xOriginal,Y,plevel,brisk);

        ci=conScalingFactor*ci-z;
        ceq=[];
        dci=[conScalingFactor*dci;-1];
        dceq=[];
    end

end