function[hDecodeReadSignal,muxCounter,readDelayCount]=elabAddrDecoderModules(...
    hN,hElab,hAddrList,hDecodeReadSignal,muxCounter,readDelayCount)





    hAddrManager=hdlturnkey.data.AddressManager(hAddrList);
    hAddrCell=hAddrManager.getAllAssignedAddressObj;
    AXI4RegisterReadbackPipelineRatio=hElab.hTurnkey.hD.hIP.getInsertAXI4PipelineRegisterEnable;



    if strcmp(AXI4RegisterReadbackPipelineRatio,'auto')
        AXI4RegisterReadbackPipelineRatioValue=35;
    elseif strcmp(AXI4RegisterReadbackPipelineRatio,'off')
        AXI4RegisterReadbackPipelineRatioValue=0;
    else
        AXI4RegisterReadbackPipelineRatioValue=str2double(AXI4RegisterReadbackPipelineRatio);
    end

    registerWidth=hAddrList.RegisterWidth;
    for ii=1:length(hAddrCell)
        hAddr=hAddrCell{ii};

        if~hAddr.Assigned||~hAddr.ElabScheduled
            continue;
        end

        if hAddr.ElabDecoderType==hdlturnkey.data.DecoderType.WRITE

            [hDecodeReadSignal,muxCounter,readDelayCount]=pirtarget.elabAddrDecoderWriteModule(...
            hN,hElab,hAddr,hDecodeReadSignal,muxCounter,readDelayCount,AXI4RegisterReadbackPipelineRatioValue,registerWidth);

        elseif hAddr.ElabDecoderType==hdlturnkey.data.DecoderType.READ

            [hDecodeReadSignal,muxCounter,readDelayCount]=pirtarget.elabAddrDecoderReadModule(...
            hN,hElab,hAddr,hDecodeReadSignal,muxCounter,readDelayCount,AXI4RegisterReadbackPipelineRatioValue,registerWidth);

        elseif hAddr.ElabDecoderType==hdlturnkey.data.DecoderType.STROBE

            pirtarget.elabAddrDecoderStrobeModule(hN,hElab,hAddr);

        else
            error(message('hdlcommon:workflow:UnsupportedAddressMode',char(hAddr.ElabDecoderType)));
        end
    end

end
