function appendToConstraintConditions(vcd,constraintExpr,doSimplify)





    numConstraints=numel(vcd.Constraints);
    for idx=1:numConstraints
        constraintName=vcd.Constraints(idx).Name;
        constraintCondition=vcd.Constraints(idx).Condition;
        appendedCondition=['(',constraintCondition,')',constraintExpr];
        if doSimplify
            try
                appendedCondition=slInternal('SimplifyVarCondExpr',appendedCondition);
            catch cause


                excep=MException(message("Simulink:VariantManager:SimplifyConstraintFailed",...
                appendedCondition));
                excep=excep.addCause(cause);
                throwAsCaller(excep);
            end
        end
        vcd.setGlobalConstraintCondition(constraintName,appendedCondition);
    end
end
