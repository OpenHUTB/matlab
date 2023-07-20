function addCheck(this,childObj)




    if isa(childObj,'ModelAdvisor.Check')
        this.CheckTitleIDs{end+1}=childObj.ID;
        this.addChildren(childObj.ID);
    elseif ischar(childObj)
        this.CheckTitleIDs{end+1}=childObj;
        this.addChildren(childObj);
    else
        DAStudio.error('Simulink:tools:MAUnsupportedObject','ModelAdvisor.Node');
    end




