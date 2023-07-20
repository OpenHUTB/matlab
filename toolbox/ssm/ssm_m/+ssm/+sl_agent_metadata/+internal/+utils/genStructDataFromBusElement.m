function structBusElement=genStructDataFromBusElement(objBusElement)




    if isempty(objBusElement)
        return;
    end

    structBusElement=ssm.sl_agent_metadata.internal.utils.getDefaultBusElementStruct();
    structBusElement=ssm.sl_agent_metadata.internal.utils.copyStructFields(structBusElement,objBusElement);
end

