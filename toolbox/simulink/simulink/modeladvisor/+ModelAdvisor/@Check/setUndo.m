function setUndo(this,action)




    if isa(action,'ModelAdvisor.Action')
        this.Undo=action;
    else
        DAStudio.error('Simulink:tools:MAInvalidParam','ModelAdvisor.Action object');
    end
