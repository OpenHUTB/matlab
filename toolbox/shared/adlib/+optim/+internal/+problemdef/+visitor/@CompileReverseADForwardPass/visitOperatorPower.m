function visitOperatorPower(visitor,op,Node)











    storeChildMemory(visitor,1);


    visitUnaryOperator(visitor,op,Node);



    if~op.ExponentIsOptimExpr&&~integerExponent(op)
        exponentIdx=visitor.NumExtraParams;
        exponentName=visitor.ExtraParamsName+"{"+exponentIdx+"}";
        isFixedVar=true;
        storeForwardMemoryRAD(visitor,exponentName,isFixedVar);
    end

end
