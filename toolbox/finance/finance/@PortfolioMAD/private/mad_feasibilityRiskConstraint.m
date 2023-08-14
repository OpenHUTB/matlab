function[ci,ceq,dci,dceq]=mad_feasibilityRiskConstraint(x,Y,...
    madlimit,conScalingFactor)




















    xOriginal=x(1:end-1);

    z=x(end);


    if nargout<=2

        ci=mad_function_as_constraint(xOriginal,Y,madlimit);

        ci=conScalingFactor*ci-z;
        ceq=[];
    else

        [ci,~,dci,~]=mad_function_as_constraint(xOriginal,Y,madlimit);

        ci=conScalingFactor*ci-z;
        ceq=[];
        dci=[conScalingFactor*dci;-1];
        dceq=[];
    end

end