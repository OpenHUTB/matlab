function success=setCheckResultMap(this,newvalue)




    if~isempty(this.ActiveCheck)

        convertedValue={};
        if ischar(newvalue)
            newvalue={newvalue};
        end
        if iscell(newvalue)
            iscellformat=true;
        else
            iscellformat=false;
        end
        for i=1:length(newvalue)
            if iscellformat
                temp=Simulink.ID.getSID(newvalue{i});
            else
                temp=Simulink.ID.getSID(newvalue(i));
            end
            if~isempty(temp)
                convertedValue{end+1}=temp;%#ok<AGROW>
            end
        end
        if~isempty(convertedValue)
            this.ActiveCheck.ProjectResultData=[this.ActiveCheck.ProjectResultData...
            ,convertedValue];
        end
        success=true;
    else
        DAStudio.error('Simulink:tools:MACanOnlyCallWhileExecuteCheckCallback','setCheckResult');
    end
