function val=getChildren(this)




    if isa(this,'ModelAdvisor.Group')
        val=[this.ChildrenObj{:}]';
    else
        val=[];
    end

