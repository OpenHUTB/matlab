function runContinue(this)





    if modeladvisorprivate('modeladvisorutil2','IamInsideRunToFailScope',this)
        this.MAObj.R2FStart.runToFail(this);
    else
        MSLDiagnostic('Simulink:tools:MANothingtoContinue').reportAsWarning;
    end
