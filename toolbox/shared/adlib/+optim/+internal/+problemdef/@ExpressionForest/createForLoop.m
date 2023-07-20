function createForLoop(obj,loopVariable,loopRange,loopBody,loopLevel,PtiesVisitor)



















    tree=optim.internal.problemdef.ExpressionTree;

    loopVarTree=forest2tree(loopVariable);


    createForLoop(tree,loopVarTree,loopRange,loopBody,loopLevel,PtiesVisitor);


    tree2forest(obj,tree);
end
