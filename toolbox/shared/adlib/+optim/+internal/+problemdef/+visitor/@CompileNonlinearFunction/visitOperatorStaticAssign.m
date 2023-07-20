function visitOperatorStaticAssign(visitor,~,Node)





    LHS=Node.ExprLeft;
    leftVarName=popNode(visitor,LHS);


    addParens=0;
    rightVarName=getChildArgumentName(visitor,2,addParens);


    asmtStr=leftVarName+" = "+rightVarName+";"+newline;


    addToExprBody(visitor,asmtStr);

end
