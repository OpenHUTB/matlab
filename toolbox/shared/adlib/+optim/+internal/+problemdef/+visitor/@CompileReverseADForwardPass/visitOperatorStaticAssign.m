function visitOperatorStaticAssign(visitor,Op,Node)





    curIsNodeLHS=visitor.IsNodeLHS(Node.ExprLeft.VisitorIndex);
    fixedVar=true;
    storeForwardMemoryRAD(visitor,curIsNodeLHS,fixedVar);
    visitor.IsNodeLHS(Node.ExprLeft.VisitorIndex)=true;


    visitOperatorStaticAssign@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,Op,Node);

end
