function val=getHierarchicalChildren(this)




    val=[];
    for i=1:length(this.ChildrenObj)
        if this.ChildrenObj{i}.Visible
            val=[val,this.ChildrenObj{i}];
        end
    end



