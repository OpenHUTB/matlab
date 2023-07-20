function[CbmultOutDlySig,CrmultOutDlySig,multLatency]=elabFIRGain(this,filterKernelNet,...
    CbpreAddOutSig,CrpreAddOutSig,coeffs,multPreDelay,multPostDelay,blockInfo,...
    sigInfo)%#ok<INUSL>







    numCoeffs=numel(coeffs);


    for ii=1:numCoeffs


        inSig=CbpreAddOutSig(ii);
        if~hdlsignalisdouble(inSig)
            mult1Type=inSig.Type;
            mult2Type=sigInfo.coeffType;
            multWL=mult1Type.WordLength+mult2Type.WordLength;
            multFL=mult1Type.FractionLength+mult2Type.FractionLength;
            multS=any([mult1Type.Signed,mult2Type.Signed]==1);
            multType=filterKernelNet.getType('FixedPoint','Signed',multS,...
            'WordLength',multWL,'FractionLength',multFL);
        else
            multType=inSig.Type;
        end




        inDlySig=filterKernelNet.addSignal(mult1Type,['multInReg',num2str(ii)]);
        predelay=pirelab.getIntDelayComp(filterKernelNet,inSig,inDlySig,...
        multPreDelay,['multInDelay',num2str(ii)]);
        predelay.addComment([num2str(multPreDelay),' delays before multiplication (along Cb data path)']);


        multOutSig=filterKernelNet.addSignal(multType,['multOut',num2str(ii)]);
        weight=pirelab.getGainComp(filterKernelNet,inDlySig,multOutSig,coeffs(ii),...
        blockInfo.gainMode,blockInfo.gainOptimMode);
        weight.addComment(['Scaled by coefficient ',num2str(double(coeffs(ii))),' (along Cb data path)']);


        CbmultOutDlySig(ii)=filterKernelNet.addSignal(multType,...
        ['multOutReg',num2str(ii)]);%#ok<AGROW>
        postdelay=pirelab.getIntDelayComp(filterKernelNet,multOutSig,CbmultOutDlySig(ii),...
        multPostDelay,['multOutDelay',num2str(ii)]);
        postdelay.addComment([num2str(multPostDelay),' delays after multiplication (along Cb data path)']);


        inSig=CrpreAddOutSig(ii);
        if~hdlsignalisdouble(inSig)
            mult1Type=inSig.Type;
            mult2Type=sigInfo.coeffType;
            multWL=mult1Type.WordLength+mult2Type.WordLength;
            multFL=mult1Type.FractionLength+mult2Type.FractionLength;
            multS=any([mult1Type.Signed,mult2Type.Signed]==1);
            multType=filterKernelNet.getType('FixedPoint','Signed',multS,...
            'WordLength',multWL,'FractionLength',multFL);
        else
            multType=inSig.Type;
        end




        inDlySig=filterKernelNet.addSignal(mult1Type,['multInReg',num2str(ii)]);
        predelay=pirelab.getIntDelayComp(filterKernelNet,inSig,inDlySig,...
        multPreDelay,['multInDelay',num2str(ii)]);
        predelay.addComment([num2str(multPreDelay),' delays before multiplication (along Cr data path)']);


        multOutSig=filterKernelNet.addSignal(multType,['multOut',num2str(ii)]);
        weight=pirelab.getGainComp(filterKernelNet,inDlySig,multOutSig,coeffs(ii),...
        blockInfo.gainMode,blockInfo.gainOptimMode);
        weight.addComment(['Scaled by coefficient ',num2str(double(coeffs(ii))),' (along Cr data path)']);


        CrmultOutDlySig(ii)=filterKernelNet.addSignal(multType,...
        ['multOutReg',num2str(ii)]);%#ok<AGROW>
        postdelay=pirelab.getIntDelayComp(filterKernelNet,multOutSig,CrmultOutDlySig(ii),...
        multPostDelay,['multOutDelay',num2str(ii)]);
        postdelay.addComment([num2str(multPostDelay),' delays after multiplication (along Cr data path)']);

    end


    multLatency=4;

end
