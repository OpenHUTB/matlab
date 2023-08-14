function val=getHierarchicalChildren(this)




    if isempty(this.ModelName)
        this.refresh;
    end

    val=[];

