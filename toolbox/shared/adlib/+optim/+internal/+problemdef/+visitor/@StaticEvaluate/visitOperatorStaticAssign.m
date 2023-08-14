function visitOperatorStaticAssign(visitor,~,Node)





    valRHS=popChild(visitor,2);


    Node.ExprLeft.Value=valRHS;

end
