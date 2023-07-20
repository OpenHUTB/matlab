function[c,isMonomialRoot,monomialFactor]=markMonomialTerms(tree)













    visitor=optim.internal.problemdef.visitor.MarkMonomialRoots;
    visitTree(visitor,tree);
    [c,isMonomialRoot,monomialFactor]=getOutputs(visitor);

end
