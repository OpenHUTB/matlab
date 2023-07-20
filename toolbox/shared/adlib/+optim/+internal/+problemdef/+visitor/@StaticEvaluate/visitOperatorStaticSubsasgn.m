function visitOperatorStaticSubsasgn(visitor,Op,Node)





    LHS=Node.ExprLeft;
    leftVal=LHS.Value;


    rightVal=popChild(visitor,2);


    val=evaluate(Op,leftVal,rightVal,visitor);


    LHS.Value=val;

end
