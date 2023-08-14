function nonVirtualSrc=getNonVirtualSrc(blkH,port)




    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    pHArray=get_param(blkH,'PortHandles');
    numIn=numel(pHArray.Inport);
    numEnable=numel(pHArray.Enable);
    numTrigger=numel(pHArray.Trigger);
    if port<numIn
        pH=pHArray.Inport(port+1);
    elseif port<(numIn+numEnable)
        pH=pHArray.Enable(port+1-numIn);
    elseif port<(numIn+numEnable+numTrigger)
        pH=pHArray.Trigger(port+1-numIn-numEnable);
    else
        error('Unknown block port requested.');
    end

    lh=get_param(pH,'Line');
    sph=get_param(lh,'NonVirtualSrcPorts');
    nonVirtualSrc=get_param(sph,'ParentHandle');
    nonVirtualSrc=slci.internal.getOrigRootIOPort(nonVirtualSrc,'Inport');

end
