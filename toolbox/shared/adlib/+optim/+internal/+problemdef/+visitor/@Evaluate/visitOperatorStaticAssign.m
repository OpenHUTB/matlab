function visitOperatorStaticAssign(visitor,~,Node)





    valRHS=popChild(visitor,2);


    pushNode(visitor,Node.ExprLeft,valRHS);

end
