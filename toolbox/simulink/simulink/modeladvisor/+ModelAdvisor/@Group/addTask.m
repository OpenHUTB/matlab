function addTask(this,childObj)




    if isa(childObj,'ModelAdvisor.Task')
        this.addChildren(childObj);
    else
        DAStudio.error('Simulink:tools:MAUnsupportedObject','ModelAdvisor.Task');
    end




