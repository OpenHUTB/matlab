function visitOperatorStaticAssign(visitor,~,Node)





    LHS=Node.ExprLeft;
    lhsJacName=popNode(visitor,LHS);
    lhsOldJacName=lhsJacName+"_old";
    lhsNumParens=0;
    lhsIsArgOrVar=true;
    lhsIsAllZero=false;


    visitor.ExprBody=visitor.ExprBody+...
    lhsOldJacName+" = "+lhsJacName+";"+newline+...
    lhsJacName+" = 0;"+newline;


    push(visitor,lhsOldJacName,lhsNumParens,lhsIsArgOrVar,lhsIsAllZero);


    curIsNodeLHS=getForwardMemory(visitor);
    visitor.IsNodeLHS(Node.ExprLeft.VisitorIndex)=curIsNodeLHS;

end
