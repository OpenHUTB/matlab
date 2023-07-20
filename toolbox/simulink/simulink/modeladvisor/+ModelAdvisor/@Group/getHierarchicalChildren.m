function val=getHierarchicalChildren(this)




    val={};
    for i=1:length(this.ChildrenObj)
        if~this.ChildrenObj{i}.Hide
            val=[val,this.ChildrenObj{i}];%#ok<AGROW>
        end
    end
