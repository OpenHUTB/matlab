function success=setCheckResult(this,newvalue)






    if~isempty(this.ActiveCheck)&&strcmp(this.stage,'ExecuteCheckCallback')
        this.ActiveCheck.Result=newvalue;
        success=true;
    else
        DAStudio.error('Simulink:tools:MACanOnlyCallWhileExecuteCheckCallback','setCheckResult');
    end
