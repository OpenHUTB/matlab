function visitOperatorStaticSubsasgn(visitor,Op,Node)





    LHS=Node.ExprLeft;
    [bLeft,ALeft]=popNode(visitor,LHS);

    [bRight,ARight]=popChild(visitor,2);



    linIdx=getLinIndex(Op,Op.LhsSize,visitor);

    nVar=visitor.TotalVar;

    [Aval,bval]=visitor.extractLinearCoefficientsForSubsasgn(ALeft,bLeft,ARight,bRight,linIdx,nVar);


    pushNode(visitor,LHS,Aval,bval);

end
