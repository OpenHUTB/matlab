function elabOneCoeffMultiply(this,filterKernelNet,nonZeroTapOutSig,...
    nonZeroCoeffs,coeffInSig,inSig,outSig,blockInfo,sigInfo,...
    multPreDelay,multPostDelay)%#ok<INUSL>








    mult1Type=sigInfo.DataInType;
    mult2Type=sigInfo.coeffType;
    wl=mult1Type.WordLength+mult2Type.WordLength;
    fl=mult1Type.FractionLength+mult2Type.FractionLength;
    s=any([mult1Type.Signed,mult2Type.Signed]==1);
    multType=filterKernelNet.getType('FixedPoint','Signed',s,'WordLength',wl,...
    'FractionLength',fl);




    inDlySig=filterKernelNet.addSignal(sigInfo.DataInType,'multInReg');
    pirelab.getIntDelayComp(filterKernelNet,nonZeroTapOutSig,inDlySig,...
    multPreDelay,'multInDelay');

    multOutSig=filterKernelNet.addSignal(multType,'multOut');

    if blockInfo.coeffFromPort

        coeffDlySig=filterKernelNet.addSignal(sigInfo.coeffType,'coeffInReg');
        pirelab.getIntDelayComp(filterKernelNet,coeffInSig,coeffDlySig,...
        multPreDelay,'multCoeffInDelay');

        pirelab.getMulComp(filterKernelNet,[inDlySig,coeffDlySig],multOutSig);
    else
        pirelab.getGainComp(filterKernelNet,inDlySig,multOutSig,...
        nonZeroCoeffs(1),blockInfo.gainMode,blockInfo.gainOptimMode);
    end


    multOutDlySig=filterKernelNet.addSignal(multType,'multOutReg');
    pirelab.getIntDelayComp(filterKernelNet,multOutSig,multOutDlySig,...
    multPostDelay,'multOutDelay');

    pirelab.getDTCComp(filterKernelNet,multOutDlySig,outSig(1),...
    blockInfo.RoundingMethod,blockInfo.OverflowAction);



    kernelTapLatency=floor(blockInfo.KernelWidth/2);
    processData=inSig(7);
    dlyType=outSig(2).Type;
    for ii=2:numel(outSig)


        dlyName=[inSig(ii).Name,'_match_tap_reg'];
        dlySig=filterKernelNet.addSignal(dlyType,dlyName);

        pirelab.getIntDelayEnabledComp(filterKernelNet,inSig(ii),dlySig,processData,kernelTapLatency,...
        [inSig(ii).Name,'_matchTapDelay']);


        pickSigType=dlyType;
        pickSigName=[dlySig.Name,'_vldSig'];
        pickSig=filterKernelNet.addSignal(pickSigType,pickSigName);
        pirelab.getLogicComp(filterKernelNet,[dlySig,processData],pickSig,'and');

        pirelab.getIntDelayComp(filterKernelNet,pickSig,outSig(ii),...
        (multPreDelay+multPostDelay),[inSig(ii).Name,'_matchMultDelay']);
    end

end
