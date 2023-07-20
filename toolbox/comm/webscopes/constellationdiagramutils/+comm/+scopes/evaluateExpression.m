function value=evaluateExpression(workspace,expression,ClientID,~)



    try
        wsBlock=matlabshared.scopes.WebScope.getInstance(ClientID);
        blockFullPath=wsBlock.FullPath;
        value=slResolve(expression,bdroot(blockFullPath));
        errorID='';
        errorMessage='';
    catch ME %#ok<NASGU>
        try
            value=slResolve(expression,blockFullPath);
            errorID='';
            errorMessage='';
        catch ME1
            if ischar(expression)||(isstring(expression)&&isscalar(expression))
                [value,errorID,errorMessage]=utils.evaluate(expression);
            else
                value=variableName;
                errorID=ME1.identifier;
                errorMessage=ME1.message;
            end
        end
    end

    if~isempty(errorMessage)
        throw(MException(errorID,errorMessage));
    end
end