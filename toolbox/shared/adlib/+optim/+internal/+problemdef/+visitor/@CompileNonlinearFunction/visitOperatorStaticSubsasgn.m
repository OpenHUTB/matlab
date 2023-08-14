function visitOperatorStaticSubsasgn(visitor,Op,Node)







    LHS=Node.ExprLeft;
    leftVarName=popNode(visitor,LHS);
    addParens=0;
    rightVarName=getChildArgumentName(visitor,2,addParens);




    addParens=1;
    indexingStr=visitStaticIndexingString(visitor,Op,addParens);


    subsStr=leftVarName+"("+indexingStr+") = "+...
    rightVarName+";"+newline;


    addToExprBody(visitor,subsStr);

end
