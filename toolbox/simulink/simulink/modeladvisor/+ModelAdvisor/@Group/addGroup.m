function addGroup(this,childObj)




    if isa(childObj,'ModelAdvisor.Group')||ischar(childObj)
        if isa(childObj,'ModelAdvisor.Group')&&~isa(childObj,'ModelAdvisor.Procedure')...
            &&isa(this,'ModelAdvisor.Procedure')
            DAStudio.error('Simulink:tools:MANoGroupAllowedUnderProcedure');
        else
            this.addChildren(childObj);
        end
    else
        DAStudio.error('Simulink:tools:MAUnsupportedObject','ModelAdvisor.Group');
    end




