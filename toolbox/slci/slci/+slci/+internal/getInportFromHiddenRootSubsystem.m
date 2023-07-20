function inport=getInportFromHiddenRootSubsystem(portNum)








    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
    mdl=bdroot;
    inport=[];
    try
        rootSSH=slInternal('getHiddenRootSubsystemHandle',mdl);
        rootSSHObj=get_param(rootSSH,'Object');
        rootSSHPorts=rootSSHObj.PortHandles;
        if portNum<=numel(rootSSHPorts.Inport)
            inportObj=get_param(rootSSHPorts.Inport(portNum),'Object');
            actSrc=inportObj.getActualSrc;
            assert(isvector(actSrc));
            inport=get_param(actSrc(1),'Object');
        end
    catch ME %#ok<*NASGU>
    end

end