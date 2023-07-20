function validateInitialValue(pouBlock)



    varList=slplc.utils.getVariableList(pouBlock);

    for varCount=1:numel(varList)
        varInfo=varList(varCount);


        try
            evalin('base',[varInfo.InitialValue,';']);
        catch causeException
            diagMsg=sprintf([...
'Failed to evaluate the initial value expression "%s" specified for variable "%s" in command window.'...
            ,'\nPlease make sure %s is defined in base workspace, or update the initial value in Variable Table of the block:\n%s\n\n'...
            ],...
            varInfo.InitialValue,...
            varInfo.Name,...
            varInfo.InitialValue,...
            pouBlock);
            baseException=MException('slplc:invalidInitialValue',diagMsg);
            baseException=addCause(baseException,causeException);
            throw(baseException);
        end
    end

end
