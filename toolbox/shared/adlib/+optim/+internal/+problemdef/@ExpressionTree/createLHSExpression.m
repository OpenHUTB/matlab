function LHSExprImpl=createLHSExpression(obj,lhsName)










    LHSExprImpl=optim.internal.problemdef.LHSExpressionImpl(lhsName);


    obj.Stack={LHSExprImpl};

    obj.Depth=1;

    LHSExprImpl.StackLength=1;

    obj.Type=optim.internal.problemdef.ImplType.Numeric;

end
