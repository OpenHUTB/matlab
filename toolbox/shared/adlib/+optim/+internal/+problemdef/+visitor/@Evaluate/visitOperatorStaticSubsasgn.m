function visitOperatorStaticSubsasgn(visitor,Op,Node)





    LHS=Node.ExprLeft;
    leftVal=popNode(visitor,LHS);


    rightVal=popChild(visitor,2);


    val=evaluate(Op,leftVal,rightVal,visitor);


    pushNode(visitor,LHS,val);

end
