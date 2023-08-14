function c=getHierarchicalChildren(this)




    rightSib=down(this);

    c(1:0)=handle([]);

    while~isempty(rightSib)
        c(end+1)=rightSib;%#ok<AGROW>
        rightSib=right(rightSib);
    end
