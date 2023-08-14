function visitOperatorStaticAssign(visitor,~,Node)





    [bRHS,ARHS]=popChild(visitor,2);


    pushNode(visitor,Node.ExprLeft,ARHS,bRHS);

end
