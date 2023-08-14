function val=isHierarchyReadonly(this)




    if this.InLibrary

        val=true;
    elseif~this.Enable&&strcmp(this.Type,'Task')&&~isempty(this.ParentObj)&&strcmp(this.ParentObj.Type,'Procedure')

        val=true;
    else
        val=false;
    end

