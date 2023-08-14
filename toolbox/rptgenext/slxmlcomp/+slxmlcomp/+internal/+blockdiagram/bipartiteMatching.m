function[n1,n2]=bipartiteMatching(M)










    matches=matchpairs(M,0,'max');

    n1=matches(:,1);
    n2=matches(:,2);
