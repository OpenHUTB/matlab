function names=getNonlinearInequalityConstraintNames(p)







    if isempty(p.Constraints)
        names=strings(0,1);
    elseif isstruct(p.Constraints)
        conNames=string(fieldnames(p.Constraints));
        isnonineq=structfun(@isNonlinearInequality,p.Constraints);
        names=conNames(isnonineq);
    elseif isNonlinearInequality(p.Constraints)
        names="Constraints";
    else
        names=strings(0,1);
    end

end

function isnonineq=isNonlinearInequality(constraint)

    relation=getRelation(constraint);
    isnonineq=(isQuadratic(constraint)||isNonlinear(constraint))&&~strcmp(relation,"==");

end
