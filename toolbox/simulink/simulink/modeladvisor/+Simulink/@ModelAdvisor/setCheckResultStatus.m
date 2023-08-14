function success=setCheckResultStatus(this,newvalue)






    success=false;
    if~isempty(this.ActiveCheck)&&strcmp(this.stage,'ExecuteCheckCallback')
        if isa(this.ActiveCheck,'ModelAdvisor.Check')
            if~(length(newvalue)==1)&&~ischar(newvalue)
                DAStudio.error('ModelAdvisor:engine:InvalidArgumentForsetCheckResultStatusAPI');
            end
            if ischar(newvalue)
                this.ActiveCheck.setStatus(newvalue);
            else
                this.ActiveCheck.Success=newvalue;
            end

            success=true;
        end
    else

        if(exist('qeDiagnosticSet','file')==2)
            app=Advisor.Manager.getActiveApplicationObj();
            ids=app.getChecksScheduledForExecution();
            disp(['this.ActiveCheck: ',this.ActiveCheck.Title]);
            disp(['this.stage: ',this.stage]);
            dbstack;
        end

        DAStudio.error('Simulink:tools:MACanOnlyCallWhileExecuteCheckCallback','setCheckResultStatus');
    end