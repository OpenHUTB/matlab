function[policy,initVal]=getPortComSpecInfo(model,portName,elementName)





    policy='Keep';
    initVal=[];

    if autosarinstalled()
        [policy,initVal]=autosar.api.Utils.getPortComSpecProperty(model,portName,elementName);
    end

end
