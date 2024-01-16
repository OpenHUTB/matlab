function portAdded=addOutBusElementPortBlocks(this,hP,slBlockName,tgtParentPath,hNtwkSlHandle)

    portAdded=false;
    BusPortHandle=find_system(get_param(hNtwkSlHandle,'Handle'),...
    'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','SearchDepth',1,...
    'blocktype','Outport','port',sprintf('%d',hP.getOrigPIRPortNum+1));
    if isempty(BusPortHandle)

        return;
    end

    portAdded=true;
    nPorts=numel(BusPortHandle);
    uniqueName=slpir.PIR2SL.getUniqueName(slBlockName);
    if nPorts==1&&...
        ~strcmp(get_param(BusPortHandle,'IsBusElementPort'),'on')
        gmHandle=add_block(getfullname(BusPortHandle),uniqueName);
        hP.setGMHandle(gmHandle);
    else
        gmPortHandle=add_block('simulink/Ports & Subsystems/Out Bus Element',uniqueName,'CreateNewPort','on','PortName',[get_param(BusPortHandle(1),'PortName'),'OutBus'],'Element','');
        hP.setGMHandle(gmPortHandle);
    end

end
