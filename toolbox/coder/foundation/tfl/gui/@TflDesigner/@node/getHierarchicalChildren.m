function children=getHierarchicalChildren(this)


    switch this.Type
    case{'TflTable'}
        children=[];
    otherwise
        children=this.getChildren;
    end