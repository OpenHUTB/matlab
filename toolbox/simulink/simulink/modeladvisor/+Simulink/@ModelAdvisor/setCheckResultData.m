function success=setCheckResultData(this,newvalue)






    if~isempty(this.ActiveCheck)&&strcmp(this.stage,'ExecuteCheckCallback')
        this.ActiveCheck.ResultData=newvalue;
        success=true;
    else
        DAStudio.error('Simulink:tools:MACanOnlyCallWhileExecuteCheckCallback','setCheckResultData');
    end
