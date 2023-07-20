function createStaticExpression(obj,lhsTree,stmtWrapper,type,vars)




















    obj.Stack=[{stmtWrapper},lhsTree.Stack];

    obj.Depth=getDepth(stmtWrapper)+lhsTree.Depth;

    lhsTree.Root.StackLength=2;


    obj.Type=type;
    obj.Variables=vars;

end
