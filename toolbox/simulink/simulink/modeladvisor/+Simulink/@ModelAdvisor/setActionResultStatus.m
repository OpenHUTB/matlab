function success=setActionResultStatus(this,newvalue)






    if~isempty(this.ActiveCheck)&&strcmp(this.stage,'ExecuteActionCallback')
        this.ActiveCheck.Action.Success=newvalue;
        success=true;
    else
        DAStudio.error('Simulink:tools:MACanOnlyCallWhileExecuteActionCallback','setActionResultStatus');
    end
