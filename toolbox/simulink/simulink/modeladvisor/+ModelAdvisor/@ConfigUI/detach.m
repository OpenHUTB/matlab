function detach(this)





    if~isempty(this.ParentObj)&&~this.InLibrary
        newChildrenObj={};
        for j=1:length(this.ParentObj.ChildrenObj)
            if~strcmp(this.ParentObj.ChildrenObj{j}.ID,this.ID)
                newChildrenObj{end+1}=this.ParentObj.ChildrenObj{j};%#ok<AGROW>
            end
        end
        this.disconnect;
        this.ParentObj.ChildrenObj=newChildrenObj;
        this.ParentObj.updateStates('fastmode');
        this.ParentObj={};
    end
