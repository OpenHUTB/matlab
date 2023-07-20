function archBlkHdl=getZCPeerForHarnessBlock(harnessBlkHandle)



    archBlkHdl=[];

    try


        isObjectOwnedByCUT=Simulink.harness.internal.sidmap.isObjectOwnedByCUT(get_param(harnessBlkHandle,'object'));
        isObjectParentOwnedByCUT=~isempty(get_param(harnessBlkHandle,'Parent'))&&Simulink.harness.internal.sidmap.isObjectOwnedByCUT(get_param(get_param(harnessBlkHandle,'Parent'),'object'));
        if~(isObjectOwnedByCUT||isObjectParentOwnedByCUT)
            return;
        end


        harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(bdroot(harnessBlkHandle));
        if isempty(harnessInfo.isOpen)
            return;
        end


        harnessBlkSID=get_param(harnessBlkHandle,'SID');
        if isempty(harnessBlkSID)&&strcmp(get_param(harnessBlkHandle,'Type'),'port')

            if strcmp(get_param(harnessBlkHandle,'PortType'),'inport')
                type='Inport';
            else
                type='Outport';
            end
            portNumber=get_param(harnessBlkHandle,'PortNumber');
            parentBlkHandle=get_param(get_param(harnessBlkHandle,'Parent'),'Handle');
            zcParentBlk=systemcomposer.internal.harness.getZCPeerForHarnessBlock(parentBlkHandle);
            if~isempty(zcParentBlk)
                phStruct=get_param(zcParentBlk,'PortHandles');
                archBlkHdl=phStruct.(type)(portNumber);
            end
            return;
        end


        if strcmp(harnessBlkSID,get_param(Simulink.harness.internal.getActiveHarnessCUT(harnessInfo.model),'SID'))
            archBlkHdl=harnessInfo.ownerHandle;
            return;
        end

        tokens=split(Simulink.ID.getFullName(harnessBlkHandle),'/');
        tokens2=split(harnessInfo.ownerFullPath,'/');
        for i=1:numel(tokens2)
            tokens{i}=tokens2{i};
        end
        archBlkPath=char(join(tokens,'/'));
        archBlkHdl=get_param(archBlkPath,'Handle');


        if isempty(archBlkHdl)||isempty(systemcomposer.utils.getArchitecturePeer(archBlkHdl))
            archBlkHdl=[];
        end
    catch
        archBlkHdl=[];
    end
end
