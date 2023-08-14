function visitOperatorStaticAssign(visitor,~,Node)





    [bRHS,ARHS,HRHS]=popChild(visitor,2);


    pushQuadNode(visitor,Node.ExprLeft,HRHS,ARHS,bRHS);

end
