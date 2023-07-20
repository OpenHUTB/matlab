function success=setCheckErrorSeverity(this,newvalue)






    if~isempty(this.ActiveCheck)&&strcmp(this.stage,'ExecuteCheckCallback')
        this.ActiveCheck.ErrorSeverity=newvalue;
        success=true;
    else
        DAStudio.error('Simulink:tools:MACanOnlyCallWhileExecuteCheckCallback','setCheckErrorSeverity');
    end
