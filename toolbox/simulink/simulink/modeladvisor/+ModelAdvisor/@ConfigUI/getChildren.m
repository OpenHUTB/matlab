function val=getChildren(this)




    if strcmp(this.Type,'Task')
        val=[];
    else
        val=[this.ChildrenObj{:}]';
    end


