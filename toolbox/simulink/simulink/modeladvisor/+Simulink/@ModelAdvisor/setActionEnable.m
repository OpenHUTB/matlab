function success=setActionEnable(this,newvalue)






    success=false;
    if~isempty(this.ActiveCheck)
        if isa(this.ActiveCheck.Action,'ModelAdvisor.Action')
            this.ActiveCheck.Action.Enable=newvalue;
            success=true;
        end
    else
        DAStudio.error('Simulink:tools:MACanOnlyCallWhileExecuteActionCallback','setActionResultStatus');
    end
