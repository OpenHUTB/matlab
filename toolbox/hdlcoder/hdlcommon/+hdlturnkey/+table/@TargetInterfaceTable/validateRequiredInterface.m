function validateCell=validateRequiredInterface(obj)


    validateCell={};

    interfaceIDList=obj.hTurnkey.getSupportedInterfaceIDList;


    for ii=1:length(interfaceIDList)
        interfaceID=interfaceIDList{ii};
        hInterface=obj.hTurnkey.getInterface(interfaceID);

        [needError,msgObj]=...
        hInterface.validateRequiredInterface(obj.hTableMap);

        if needError
            if obj.hTurnkey.hD.cmdDisplay
                error(msgObj);
            else
                validateCell{end+1}=hdlvalidatestruct('Error',msgObj);%#ok<AGROW>
            end
        end
    end

end

