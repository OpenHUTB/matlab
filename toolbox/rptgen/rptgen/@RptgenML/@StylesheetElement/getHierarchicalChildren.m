function c=getHierarchicalChildren(this)




    c=[];

    if isempty(this.JavaHandle)
        return;
    end
    rightSib=down(this);


    while~isempty(rightSib)
        c=[c,rightSib];%#ok
        rightSib=right(rightSib);
    end
