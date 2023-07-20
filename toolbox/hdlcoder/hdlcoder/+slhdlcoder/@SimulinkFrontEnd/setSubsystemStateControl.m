function setSubsystemStateControl(~,blockInfo,thisNetwork)



    stateControl=blockInfo.StateControl;
    ishwfriendly=false;


    if~isempty(stateControl)
        try
            controlPortSemantics=get_param(stateControl,'StateControl');
            if strcmpi(controlPortSemantics,'Synchronous')
                ishwfriendly=true;
            end
        catch
        end
    end
    thisNetwork.setHasSLHWFriendlySemantics(ishwfriendly);
end
