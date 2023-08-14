function[n1,n2]=bipartiteMatchingMatrixWrapper(Vec,M,N)
    [n1,n2]=slxmlcomp.internal.blockdiagram.bipartiteMatching(reshape(Vec,M,N));
end
