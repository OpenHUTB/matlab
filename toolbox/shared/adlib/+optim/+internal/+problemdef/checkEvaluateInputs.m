function varVal=checkEvaluateInputs(obj,varVal,msgCatalog,msgErrorID)











    if nargin<3
        msgCatalog="shared_adlib:evaluate";
        msgErrorID=msgCatalog;
    end


    if isempty(varVal)||~isstruct(varVal)
        msgId=msgCatalog+":XMustBeNonEmptyStruct";
        errorID=msgErrorID+":XMustBeNonEmptyStruct";
        throwAsCaller(MException(errorID,getString(message(msgId))));
    end


    if~isscalar(varVal)
        msgId=msgCatalog+":XMustBeScalarStruct";
        errorID=msgErrorID+":XMustBeScalarStruct";
        throwAsCaller(MException(errorID,getString(message(msgId))));
    end


    fnames=fieldnames(varVal);

    vars=getVariables(obj);
    varnames=fieldnames(vars);
    for i=1:numel(varnames)

        varIdx=strcmp(varnames{i},fnames);
        if any(varIdx)


            curVar=vars.(varnames{i});

            curVarVal=varVal.(fnames{varIdx});

            if~isnumeric(curVarVal)
                msgId=msgCatalog+":XMustContainDoubles";
                errorID=msgErrorID+":XMustContainDoubles";
                throwAsCaller(MException(errorID,getString(message(msgId))));
            end

            if numel(curVar)==numel(curVarVal)


                szVar=getSize(curVar);
                curVarVal=reshape(curVarVal,szVar);
            else
                msgId=msgCatalog+":IncorrectVariableSize";
                errorID=msgErrorID+":IncorrectVariableSize";
                throwAsCaller(MException(errorID,getString(message(msgId,varnames{i},...
                getDimensionAsString(curVar)))));
            end

            varVal.(fnames{varIdx})=curVarVal;
        else

            msgId=msgCatalog+":XMustHaveAllVariables";
            errorID=msgErrorID+":XMustHaveAllVariables";
            throwAsCaller(MException(errorID,getString(message(msgId,varnames{i}))));
        end
    end
