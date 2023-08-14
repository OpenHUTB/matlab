function harnessBlkHandle=getActiveHarnessPeer(blkHandle)



    harnessBlkHandle=[];
    try

        harnessInfo=Simulink.harness.internal.getActiveHarness(bdroot(blkHandle));
        if isempty(harnessInfo)
            return;
        end


        if strcmp(getfullname(blkHandle),harnessInfo.ownerFullPath)
            harnessBlkHandle=harnessInfo.ownerHandle;
            return;
        end


        slBlkSID=get_param(blkHandle,'SID');

        if isempty(slBlkSID)&&strcmp(get_param(blkHandle,'Type'),'port')

            if strcmp(get_param(blkHandle,'PortType'),'inport')
                type='Inport';
            else
                type='Outport';
            end
            portNumber=string(get_param(blkHandle,'PortNumber'));
            parentBlkHdl=get_param(get_param(blkHandle,'Parent'),'Handle');
            zcParentBlk=systemcomposer.internal.harness.getActiveHarnessPeer(parentBlkHdl);
            if~isempty(zcParentBlk)
                ph=get_param(zcParentBlk,'PortHandles');
                for id=1:length(ph.(type))
                    if strcmp(portNumber,string(get_param(ph.(type)(id),'PortNumber')))
                        harnessBlkHandle=ph.(type)(id);
                        return;
                    end
                end
            else
                return;
            end
        end
        CUTSID=get_param(Simulink.harness.internal.getActiveHarnessCUT(harnessInfo.model),'SID');
        harnessBlkSID=[harnessInfo.name,':',CUTSID,':',slBlkSID];
        harnessBlkHandle=Simulink.ID.getHandle(harnessBlkSID);
    catch

        harnessBlkHandle=[];
    end
end
