function c=getHierarchicalChildren(dao)




    rightSib=down(dao);
    c=[];

    while~isempty(rightSib)
        c=[c,rightSib];
        rightSib=right(rightSib);
    end