function[result,value]=evalValidateReferenceConstellation(workspace,variableName,clientID,~)







    try
        wsBlock=matlabshared.scopes.WebScope.getInstance(clientID);
        blockFullPath=wsBlock.FullPath;
        value=slResolve(variableName,bdroot(blockFullPath));
        errorID='';
        errorMessage='';
    catch ME %#ok<NASGU>
        try
            value=slResolve(variableName,blockFullPath);
            errorID='';
            errorMessage='';
        catch ME1
            if ischar(variableName)||(isstring(variableName)&&isscalar(variableName))
                [value,errorID,errorMessage]=utils.evaluate(variableName);
            else
                value=variableName;
                errorID=ME1.identifier;
                errorMessage=ME1.message;
            end
        end
    end
    if~isempty(errorMessage)
        throw(MException(errorID,errorMessage));
    else
        if iscolumn(value)
            value=(value)';
        end
        result{1}=real(value);
        result{2}=imag(value);
        value=mat2str(value);
    end
end


