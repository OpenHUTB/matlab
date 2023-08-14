function initPOUVarSS(varSSBlock)




    if~strcmpi(slplc.utils.getModelGenerationStatus(varSSBlock),...
        'none')
        return
    end

    pouBlock=slplc.utils.getParentPOU(varSSBlock);
    if isempty(pouBlock)
        return
    end

    varList=slplc.utils.getVariableList(pouBlock);
    if isempty(varList)
        return
    end

    toDeleteVarNames={};
    for varCount=1:numel(varList)
        varName=varList(varCount).Name;
        varParamStr=['PLCVar',varName];
        varList(varCount).Scope=get_param(varSSBlock,[varParamStr,'Scope']);
        varList(varCount).PortType=get_param(varSSBlock,[varParamStr,'PortType']);
        varList(varCount).PortIndex=get_param(varSSBlock,[varParamStr,'PortIndex']);
        varList(varCount).DataType=get_param(varSSBlock,[varParamStr,'DataType']);
        varList(varCount).Size=get_param(varSSBlock,[varParamStr,'Size']);
        varList(varCount).InitialValue=get_param(varSSBlock,[varParamStr,'InitialValue']);

        if strcmpi('on',get_param(varSSBlock,[varParamStr,'ToDelete']))
            toDeleteVarNames{end+1}=varName;%#ok<AGROW>
        end
    end


    slplc.utils.setVariableList(pouBlock,varList,'VariableSS');


    varList=slplc.utils.deleteVariables(varList,toDeleteVarNames);
    slplc.utils.setVariableList(pouBlock,varList);


    slplc.utils.updateDataBlocks(pouBlock);
end
