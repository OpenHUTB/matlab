function yesno=isEditablePropertyInInspector(this,propName)






    if isempty(this.dataModelObj)
        yesno=false;
        return;
    end

    if this.readOnly
        yesno=false;
    elseif any(strcmp(propName,this.readOnlyProperties))
        yesno=false;
    elseif this.RequirementSet.isBackedBySlx()&&strcmp(propName,'Summary')
        yesno=false;
    elseif this.dataModelObj.external&&strcmp(propName,'CustomID')
        yesno=false;
    else
        yesno=~this.dataModelObj.locked&&~this.RequirementSet.isBackingModelLocked();
    end

end
