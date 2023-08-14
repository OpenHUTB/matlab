function visitOperatorStaticSubsasgn(visitor,~,Node)





    LHS=Node.ExprLeft;
    lhsJacName=popNode(visitor,LHS);
    lhsOldJacName=lhsJacName+"_old";





    indexingBody=getForwardMemory(visitor);
    linIdxParens=getForwardMemory(visitor);
    linIdxStr=getForwardMemory(visitor);


    leftBody=...
    lhsOldJacName+" = "+lhsJacName+";"+newline+...
    lhsJacName+"("+linIdxStr+", :)"+" = 0;"+newline;

    if~strcmp(linIdxStr,':')


        leftJacStr="arg"+visitor.getNumArgs();
        leftBody=leftBody+leftJacStr+" = SubsasgnAdjoint("+...
        lhsOldJacName+", "+linIdxStr+", "+numel(Node.ExprRight)+...
        ");"+newline;

        PackageLocation="optim.problemdef.gradients.indexing";
        visitor.PkgDepends(end+1)=PackageLocation;
    else

        leftJacStr=lhsOldJacName;
    end

    leftNumParens=linIdxParens+1;
    lhsJacIsArgOrVar=false;
    lhsJacIsAllZero=false;
    visitor.ExprBody=visitor.ExprBody+indexingBody+leftBody;

    push(visitor,leftJacStr,leftNumParens,lhsJacIsArgOrVar,lhsJacIsAllZero);


    curIsNodeLHS=getForwardMemory(visitor);
    visitor.IsNodeLHS(Node.ExprLeft.VisitorIndex)=curIsNodeLHS;
end
