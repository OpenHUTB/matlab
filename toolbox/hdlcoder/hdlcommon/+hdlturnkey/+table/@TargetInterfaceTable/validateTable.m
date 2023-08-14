function validateCell=validateTable(obj)









    validateCell={};



    validateCellRI=obj.validateRequiredInterface;
    validateCell=[validateCell,validateCellRI];


    validateCell=obj.hTurnkey.hStream.validateStreamingInterface(validateCell);


    validateCell=obj.hTurnkey.hExecMode.validateExecutionMode(validateCell);


    interfaceIDList=obj.hTableMap.getAssignedInterfaces;
    for ii=1:length(interfaceIDList)
        interfaceID=interfaceIDList{ii};
        hInterface=obj.hTurnkey.getInterface(interfaceID);
        validateCell=hInterface.validateFullTable(validateCell,obj);
    end




    if obj.hTurnkey.hD.isIPCoreGen&&~obj.hTurnkey.hD.isGenericIPPlatform||obj.hTurnkey.hD.isDynamicWorkflow
        validateCellCallback=hdlturnkey.plugin.runCallbackPostTargetInterface(obj.hTurnkey.hD);
        validateCell=[validateCell,validateCellCallback];

        hRD=obj.hTurnkey.hD.hIP.getReferenceDesignPlugin;
        hdlturnkey.plugin.runRDProcessPostTargetInterface(hRD,obj.hTurnkey.hD);
    end





    for ii=1:length(obj.hIOPortList.InputPortNameList)
        portName=obj.hIOPortList.InputPortNameList{ii};
        hInterface=obj.hTableMap.getInterface(portName);
        if hInterface.isEmptyInterface
            validateCell{end+1}=hdlvalidatestruct('Warning',...
            message('hdlcommon:hdlcommon:InterfaceNotAssigned',portName));%#ok<*AGROW>
        end
    end

    oneOutportAssigned=false;
    for ii=1:length(obj.hIOPortList.OutputPortNameList)
        portName=obj.hIOPortList.OutputPortNameList{ii};
        hInterface=obj.hTableMap.getInterface(portName);
        if hInterface.isEmptyInterface
            validateCell{end+1}=hdlvalidatestruct('Warning',...
            message('hdlcommon:hdlcommon:InterfaceNotAssigned',portName));
        else
            oneOutportAssigned=true;
        end
    end


    if~oneOutportAssigned
        if obj.hTurnkey.hD.cmdDisplay
            error(message('hdlcommon:workflow:NoInterfaceAssigned'));
        else
            validateCell{end+1}=hdlvalidatestruct('Error',...
            message('hdlcommon:workflow:NoInterfaceAssigned'));
        end
    end


    validateCell=downstream.tool.filterEmptyCell(validateCell);

end


