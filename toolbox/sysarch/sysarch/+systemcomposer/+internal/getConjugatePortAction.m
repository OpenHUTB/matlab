function[newPortAction,newPortBlockName,newPortType]=getConjugatePortAction(aPort)



    import systemcomposer.architecture.model.core.PortAction
    isBusPort=get_param(aPort.SimulinkHandle(1),'isBusElementPort')=="on";
    aPortImpl=aPort.getImpl;
    if aPortImpl.getPortAction==PortAction.REQUEST
        newPortAction=PortAction.PROVIDE;
        newPortType='Outport';
        if isBusPort
            newPortBlockName='Out Bus Element';
        else
            newPortBlockName='Out1';
        end
    elseif aPortImpl.getPortAction==PortAction.PROVIDE
        newPortAction=PortAction.REQUEST;
        newPortType='Inport';
        if isBusPort
            newPortBlockName='In Bus Element';
        else
            newPortBlockName='In1';
        end
    elseif aPortImpl.getPortAction==PortAction.CLIENT
        newPortAction=PortAction.SERVER;
        newPortType='Outport';
        newPortBlockName='Out Bus Element';
    elseif aPortImpl.getPortAction==PortAction.SERVER
        newPortAction=PortAction.CLIENT;
        newPortType='Inport';
        newPortBlockName='In Bus Element';
    else
        error('No action done for other ports');
    end
end