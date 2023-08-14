function updateID(this,updatePublishProperty,updateProtectedProperty)





    if isa(this.ParentObj,'ModelAdvisor.ConfigUI')
        newID=[this.ParentObj.ID,'_','$',this.DisplayName];
        dupIDObj=findobj([this.ParentObj.getChildren],'ID',newID);
        while~isempty(dupIDObj)
            newID=[newID,'1'];%#ok<AGROW>
            dupIDObj=findobj([this.ParentObj.getChildren],'ID',newID);
        end
        this.ID=newID;

        this.MAObj=this.ParentObj.MAObj;
        if updatePublishProperty

            if~strcmp(this.ParentObj.ID,'SysRoot')
                this.Published=false;
            else
                this.Published=true;
            end
        end
        if updateProtectedProperty
            this.Protected=false;
        end
    end
    for i=1:length(this.ChildrenObj)
        updateID(this.ChildrenObj{i},updatePublishProperty,updateProtectedProperty);
    end
