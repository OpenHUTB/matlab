function elabOneCoeffMultiplyMultipixel(this,filterKernelNet,nonZeroTapOutSig,...
    nonZeroCoeffs,coeffInSig,inSig,outSig,blockInfo,sigInfo,...
    multPreDelay,multPostDelay)%#ok<INUSL>








    mult1Type=sigInfo.DataInType.BaseType;
    mult2Type=sigInfo.coeffType.BaseType;
    wl=mult1Type.WordLength+mult2Type.WordLength;
    fl=mult1Type.FractionLength+mult2Type.FractionLength;
    s=any([mult1Type.BaseType.Signed,mult2Type.BaseType.Signed]==1);
    multType=filterKernelNet.getType('FixedPoint','Signed',s,'WordLength',wl,...
    'FractionLength',fl);

    for ii=1:1:blockInfo.NumberOfPixels



        inDlySig(ii)=filterKernelNet.addSignal(sigInfo.DataInType.BaseType,'multInReg');%#ok<AGROW>
        pirelab.getIntDelayComp(filterKernelNet,nonZeroTapOutSig(ii,:),inDlySig(ii),...
        multPreDelay,'multInDelay');

        multOutSig(ii)=filterKernelNet.addSignal(multType,'multOut');%#ok<AGROW>

        if blockInfo.coeffFromPort

            coeffDlySig(ii)=filterKernelNet.addSignal(sigInfo.coeffType,'coeffInReg');%#ok<AGROW>
            pirelab.getIntDelayComp(filterKernelNet,coeffInSig,coeffDlySig(ii),...
            multPreDelay,'multCoeffInDelay');

            pirelab.getMulComp(filterKernelNet,[inDlySig(ii),coeffDlySig(ii)],multOutSig(ii));
        else
            pirelab.getGainComp(filterKernelNet,inDlySig(ii),multOutSig(ii),...
            nonZeroCoeffs(1),blockInfo.gainMode,blockInfo.gainOptimMode);
        end


        multOutDlySig(ii)=filterKernelNet.addSignal(multType,'multOutReg');%#ok<AGROW>
        pirelab.getIntDelayComp(filterKernelNet,multOutSig(ii),multOutDlySig(ii),...
        multPostDelay,'multOutDelay');
    end


    firVecType=pirelab.getPirVectorType(multType,[blockInfo.NumberOfPixels,1],1);

    fpFIROutSigVec=filterKernelNet.addSignal2('Type',firVecType,'Name','FilterOut');
    pirelab.getMuxComp(filterKernelNet,multOutDlySig(:),fpFIROutSigVec);


    pirelab.getDTCComp(filterKernelNet,fpFIROutSigVec,outSig(1),blockInfo.RoundingMethod,blockInfo.OverflowAction);



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