function visitOperatorStaticAssign(visitor,~,Node)





    [typeRHS,valRHS]=popChild(visitor,2);


    pushNode(visitor,Node.ExprLeft,typeRHS,valRHS);

end
