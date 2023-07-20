function setAction(this,action)




    if isa(action,'ModelAdvisor.Action')
        this.Action=action;
    else
        DAStudio.error('Simulink:tools:MAInvalidParam','ModelAdvisor.Action object');
    end
