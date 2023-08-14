function success=setInvalidActionObject(this,ObjectsCellarray)







    if~isempty(this.ActiveCheck)&&strcmp(this.stage,'ExecuteCheckCallback')
        for i=1:length(ObjectsCellarray)
            ObjectsCellarray{i}=get_param(ObjectsCellarray{i},'handle');
        end
        this.ActiveCheck.InvalidActionObject=ObjectsCellarray;
        success=true;
    else
        DAStudio.error('Simulink:tools:MACanOnlyCallWhileExecuteCheckCallback','setInvalidActionObject');
    end
