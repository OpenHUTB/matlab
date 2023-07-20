function val=getHierarchicalChildren(this)



    switch this.Type
    case{'TflTable'}
        val=[];
    otherwise
        val=this.Children(:);
    end

