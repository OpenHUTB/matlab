function val=isHierarchyReadonly(this)



    val=false;
    return



    if(this.Selected&&~this.Enable&&~strcmp(this.Type,'Container'))
        val=false;
    elseif(~this.Selected&&~strcmp(this.Type,'Container'))||(~this.Enable)
        val=true;
    else
        val=false;
    end

