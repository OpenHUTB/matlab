function[isNeeded,dut_enb_signal]=scheduleDUTEnableWiring(obj,hN,hElab)









    isNeeded=false;
    dut_enb_signal=[];




    if hElab.hTurnkey.hStream.isAutoReadyDisabled
        return;
    end

    channelIDlist=obj.hChannelList.getAssignedChannels;
    for ii=1:length(channelIDlist)
        channelID=channelIDlist{ii};
        hChannel=obj.hChannelList.getChannel(channelID);
        if hChannel.ChannelDirType==hdlturnkey.IOType.OUT&&...
            ~hChannel.isReadyPortAssigned





            hChannel.NeedAutoReadyWiring=true;

            isNeeded=true;
            ufix1Type=pir_ufixpt_t(1,0);


            auto_ready_signal=hN.addSignal(ufix1Type,hChannel.AutoReadyConnectionID);
            hElab.setInternalSignal(hChannel.AutoReadyConnectionID,auto_ready_signal);


            dut_enb_signal=hN.addSignal(ufix1Type,hChannel.AutoReadyDutEnbConnectionID);
            hElab.setInternalSignal(hChannel.AutoReadyDutEnbConnectionID,dut_enb_signal);
            pirelab.getUnitDelayComp(hN,auto_ready_signal,dut_enb_signal);

            break;
        end
    end

end

