function structBus=genStructDataFromBus(objBus)




    if isempty(objBus)
        return;
    end

    structBus=ssm.sl_agent_metadata.internal.utils.getDefaultBusStruct();


    ssm.sl_agent_metadata.internal.utils.copyStructFields(structBus,objBus);


    for idx=length(objBus.Elements):-1:1
        structBus.Elements(idx)=ssm.sl_agent_metadata.internal.utils.genStructDataFromBusElement(objBus.Elements(idx));
    end
end

