function elabOneCoeffMultiply(this,filterKernelNet,CbnonZero,CrnonZero,...
    nonZeroCoeffs,inSig,outSig,blockInfo,sigInfo,...
    multPreDelay,multPostDelay)%#ok<INUSL>










    mult1Type=sigInfo.DataInType;
    mult2Type=sigInfo.coeffType;
    wl=mult1Type.WordLength+mult2Type.WordLength;
    fl=mult1Type.FractionLength+mult2Type.FractionLength;
    s=any([mult1Type.Signed,mult2Type.Signed]==1);
    multType=filterKernelNet.getType('FixedPoint','Signed',s,'WordLength',wl,...
    'FractionLength',fl);





    CbinDlySig=filterKernelNet.addSignal(sigInfo.DataInType,'CbmultInReg');
    predelay=pirelab.getIntDelayComp(filterKernelNet,CbnonZero,CbinDlySig,...
    multPreDelay,'CbmultInDelay');
    predelay.addComment([num2str(multPreDelay),' delays before multiplication (along Cb data path)']);

    CrinDlySig=filterKernelNet.addSignal(sigInfo.DataInType,'CrmultInReg');
    predelay=pirelab.getIntDelayComp(filterKernelNet,CrnonZero,CrinDlySig,...
    multPreDelay,'CrmultInDelay');
    predelay.addComment([num2str(multPreDelay),' delays before multiplication (along Cr data path)']);


    CbmultOutSig=filterKernelNet.addSignal(multType,'CbmultOut');
    weight=pirelab.getGainComp(filterKernelNet,CbinDlySig,CbmultOutSig,...
    nonZeroCoeffs(1),blockInfo.gainMode,blockInfo.gainOptimMode);
    weight.addComment(['Scaled by coefficient ',num2str(double(nonZeroCoeffs(1))),' (along Cb data path)']);

    CrmultOutSig=filterKernelNet.addSignal(multType,'CrmultOut');
    weight=pirelab.getGainComp(filterKernelNet,CrinDlySig,CrmultOutSig,...
    nonZeroCoeffs(1),blockInfo.gainMode,blockInfo.gainOptimMode);
    weight.addComment(['Scaled by coefficient ',num2str(double(nonZeroCoeffs(1))),' (along Cr data path)']);


    CbmultOutDlySig=filterKernelNet.addSignal(multType,'CbmultOutReg');
    postdelay=pirelab.getIntDelayComp(filterKernelNet,CbmultOutSig,CbmultOutDlySig,...
    multPostDelay,'CbmultOutDelay');
    postdelay.addComment([num2str(multPostDelay),' delays after multiplication (along Cb data path)']);

    CrmultOutDlySig=filterKernelNet.addSignal(multType,'CrmultOutReg');
    postdelay=pirelab.getIntDelayComp(filterKernelNet,CrmultOutSig,CrmultOutDlySig,...
    multPostDelay,'CrmultOutDelay');
    postdelay.addComment([num2str(multPostDelay),' delays after multiplication (along Cr data path)']);


    pirelab.getDTCComp(filterKernelNet,CbmultOutDlySig,outSig(1),...
    blockInfo.RoundingMethod,blockInfo.OverflowAction);
    pirelab.getDTCComp(filterKernelNet,CrmultOutDlySig,outSig(2),...
    blockInfo.RoundingMethod,blockInfo.OverflowAction);





    deComment={'Delay Y Component',...
    'Delay Horizontal Start',...
    'Delay Horizontal End',...
    'Delay Vertical Start',...
    'Delay Vertical End',...
    'Delay Valid'};
    assert(numel(outSig)==8);
    for ii=3:numel(outSig)
        de=pirelab.getIntDelayComp(filterKernelNet,inSig(ii+2*(numel(blockInfo.coeffs))-2),outSig(ii),...
        (multPreDelay+multPostDelay),'matchMultDelay');
        de.addComment(deComment{ii-2});

    end

end
