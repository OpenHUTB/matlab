function initControllerVarSS(varSSBlock)




    if~strcmpi(slplc.utils.getModelGenerationStatus(varSSBlock),...
        'none')
        return
    end

    controllerBlock=slplc.utils.getParentPOU(varSSBlock);
    if isempty(controllerBlock)
        return
    end

    varList=slplc.utils.getVariableList(controllerBlock);
    if isempty(varList)
        return
    end

    toDeleteVarNames={};
    for varCount=1:numel(varList)
        varName=varList(varCount).Name;
        varParamStr=['PLCVar',varName];
        varList(varCount).Address=get_param(varSSBlock,[varParamStr,'Address']);
        varList(varCount).PortIndex=get_param(varSSBlock,[varParamStr,'PortIndex']);
        varList(varCount).DataType=get_param(varSSBlock,[varParamStr,'DataType']);
        varList(varCount).Size=get_param(varSSBlock,[varParamStr,'Size']);
        varList(varCount).InitialValue=get_param(varSSBlock,[varParamStr,'InitialValue']);

        if strcmpi('on',get_param(varSSBlock,[varParamStr,'ToDelete']))
            toDeleteVarNames{end+1}=varName;%#ok<AGROW>
        end

        varMapping=get_param(varSSBlock,[varParamStr,'Mapping']);
        if strcmpi(varMapping,'Global Variable')
            portType='Hidden';
        elseif strcmpi(varMapping,'Input Symbol')
            portType='Inport';
        else
            portType='Outport';
        end
        varList(varCount).PortType=portType;
    end


    slplc.utils.setVariableList(controllerBlock,varList,'VariableSS');


    varList=slplc.utils.deleteVariables(varList,toDeleteVarNames);
    slplc.utils.setVariableList(controllerBlock,varList);


    slplc.utils.updateDataBlocks(controllerBlock);
end
