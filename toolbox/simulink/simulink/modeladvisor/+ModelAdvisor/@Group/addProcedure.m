function addProcedure(this,childObj)




    if 1||isa(childObj,'ModelAdvisor.Procedure')||ischar(childObj)
        this.addChildren(childObj);
    else
        DAStudio.error('Simulink:tools:MAUnsupportedObject','ModelAdvisor.Procedure');
    end




