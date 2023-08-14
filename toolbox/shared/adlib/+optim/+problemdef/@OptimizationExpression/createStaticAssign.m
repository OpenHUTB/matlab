function eout=createStaticAssign(elhs,erhs,PtiesVisitor)














    if isnumeric(elhs)&&~isa(elhs,'optim.problemdef.OptimizationExpression')
        elhsVal=elhs;
        elhs=optim.problemdef.OptimizationExpression({});
        createNumeric(elhs.OptimExprImpl,elhsVal);
    end


    if~isa(erhs,'optim.problemdef.OptimizationExpression')
        erhsVal=erhs;
        erhs=optim.problemdef.OptimizationExpression({});
        createNumeric(erhs.OptimExprImpl,erhsVal);
    end


    Op=optim.internal.problemdef.operator.StaticAssign.getOperator();
    eout=createStaticAssignment(elhs,erhs,Op,PtiesVisitor);


