function[isqrt,newtree,c,a]=createExprIfSqrt(tree)





















    [c,isMonomialRoot,monomialFactor]=markMonomialTerms(tree);

    isqrt=sum(isMonomialRoot)==1;

    if~isqrt

        c=0;
        a=1;
        newtree=[];
        return;
    end


    a=monomialFactor(isMonomialRoot);
    outerMonomialRootIdx=find(isMonomialRoot);



    [isqrt,innerSqrtNodeIdx]=getInnerSqrtExpression(tree,outerMonomialRootIdx);

    if~isqrt

        c=0;
        a=1;
        newtree=[];
        return;
    end



    newtree=optim.internal.problemdef.ExpressionTree;


    innerExprStackIdx=getSubExprStackIdx(tree,innerSqrtNodeIdx);
    newtree.Stack=tree.Stack(innerExprStackIdx);


    newtree.Variables=tree.Variables;


    newtree.Type=computeType(newtree);





end

function stackIdx=getSubExprStackIdx(tree,subExprRootIdx)




    subExprRootNode=tree.Stack{subExprRootIdx};


    stackIdx=subExprRootIdx-(subExprRootNode.StackLength-1:-1:0);

end
