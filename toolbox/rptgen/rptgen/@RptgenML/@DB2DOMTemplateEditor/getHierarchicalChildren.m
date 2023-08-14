function c=getHierarchicalChildren(dao)




    rightSib=down(dao);

    c=[];

    while~isempty(rightSib)
        c=[c,rightSib];%#ok
        rightSib=right(rightSib);
    end