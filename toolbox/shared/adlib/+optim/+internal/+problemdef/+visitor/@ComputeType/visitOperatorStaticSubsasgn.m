function visitOperatorStaticSubsasgn(visitor,Op,Node)





    [RHSType,RHSVal]=popChild(visitor,2);


    LHS=Node.ExprLeft;
    [LHSType,LHSVal]=popNode(visitor,LHS);


    type=optim.internal.problemdef.ImplType.typeSubsasgn([LHSType,RHSType]);


    if type==optim.internal.problemdef.ImplType.Numeric
        val=evaluate(Op,LHSVal,RHSVal,visitor);
    else
        val=[];
    end


    pushNode(visitor,LHS,type,val);

end
