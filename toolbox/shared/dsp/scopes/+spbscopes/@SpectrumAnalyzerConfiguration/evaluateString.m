function[value,errorOccured]=evaluateString(obj,strValue,propName)




    validateattributes(strValue,{'char'},{},'',propName);
    errorOccured=false;
    isSourceRunning=false;
    Framework=obj.Scope.Framework;
    if~isempty(Framework)
        src=Framework.DataSource;
        if~isempty(src)
            if isRunning(src)||isPaused(src)
                isSourceRunning=true;
            end
        end
    end
    [value,~,errStr]=obj.evaluateVariable(strValue);
    if~isempty(errStr)
        errorOccured=true;
        if isSourceRunning


            [errStr,errId]=uiservices.message('EvaluateUndefinedVariable',strValue);
            throw(MException(errId,errStr));
        end
    end
end
