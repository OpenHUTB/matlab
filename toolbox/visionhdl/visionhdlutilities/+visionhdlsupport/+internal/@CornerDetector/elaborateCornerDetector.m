function topNet=elaborateCornerDetector(this,topNet,blockInfo,insignals,outsignals)









    pixelIn=insignals(1);
    hStartIn=insignals(2);
    hEndIn=insignals(3);
    vStartIn=insignals(4);
    vEndIn=insignals(5);
    validIn=insignals(6);

    inRate=pixelIn.SimulinkRate;



    Corner=outsignals(1);
    Corner.SimulinkRate=inRate;
    blockInfo.outportCornerType=Corner.Type;
    IX=2;

    hStartOut=outsignals(IX);
    hEndOut=outsignals(IX+1);
    vStartOut=outsignals(IX+2);
    vEndOut=outsignals(IX+3);
    validOut=outsignals(IX+4);
    hStartOut.SimulinkRate=inRate;
    hEndOut.SimulinkRate=inRate;
    vStartOut.SimulinkRate=inRate;
    vEndOut.SimulinkRate=inRate;
    validOut.SimulinkRate=inRate;

    dataType=pixelIn.Type;
    ctrlType=pir_boolean_t();


    switch blockInfo.Method
    case 'FAST 5 of 8'
        blockInfo.pixelInVecDT=pirelab.getPirVectorType(dataType,3);
    case 'FAST 7 of 12'
        blockInfo.pixelInVecDT=pirelab.getPirVectorType(dataType,5);
    case 'FAST 9 of 16'
        blockInfo.pixelInVecDT=pirelab.getPirVectorType(dataType,7);
    otherwise
        blockInfo.pixelInVecDT=pirelab.getPirVectorType(dataType,3);
    end


    if blockInfo.numInputPorts==3
        minCType=insignals(7).Type;
        switch blockInfo.Method
        case 'Harris'
            blockInfo.threshType=minCType;
            minCReg=topNet.addSignal(minCType,'minThReg');
            newFrame=topNet.addSignal(ctrlType,'newFrame');
            pirelab.getLogicComp(topNet,[hStartIn,vStartIn,validIn],newFrame,'and');
            pirelab.getUnitDelayEnabledComp(topNet,insignals(7),minCReg,newFrame,'minThFrameReg',false,'',false);
            minCCast=topNet.addSignal(Corner.Type,'minThCast');
            pirelab.getDTCComp(topNet,minCReg,minCCast,'Nearest','Saturate');
        otherwise
            minCReg=topNet.addSignal(minCType,'minCReg');
            newFrame=topNet.addSignal(ctrlType,'newFrame');
            pirelab.getLogicComp(topNet,[hStartIn,vStartIn,validIn],newFrame,'and');
            pirelab.getUnitDelayEnabledComp(topNet,insignals(7),minCReg,newFrame,'minCFrameReg',false,'',false);
            minCCast=topNet.addSignal(dataType,'minCCast');
            pirelab.getDTCComp(topNet,minCReg,minCCast,'Nearest','Saturate');
        end
    end

    LMKData=topNet.addSignal(blockInfo.pixelInVecDT,'LMKDataOut');
    LMKhs=topNet.addSignal(ctrlType,'LMKhStartOut');
    LMKhe=topNet.addSignal(ctrlType,'LMKhEndOut');
    LMKvs=topNet.addSignal(ctrlType,'LMKvStartOut');
    LMKve=topNet.addSignal(ctrlType,'LMKvEndOut');
    LMKvl=topNet.addSignal(ctrlType,'LMKvalidOut');
    ShiftEnb=topNet.addSignal(ctrlType,'LMKShiftEnb');

    LMKInfo.KernelHeight=blockInfo.KernelHeight;
    LMKInfo.KernelWidth=blockInfo.KernelWidth;
    LMKInfo.MaxLineSize=blockInfo.MaxLineSize;
    LMKInfo.PaddingMethod=blockInfo.PaddingMethod;
    LMKInfo.PaddingValue=0;
    LMKInfo.DataType=dataType;
    LMKInfo.BiasUp=true;

    LMKNet=this.addLineBuffer(topNet,LMKInfo,inRate);
    pirelab.instantiateNetwork(topNet,LMKNet,[pixelIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn],...
    [LMKData,LMKhs,LMKhe,LMKvs,LMKve,LMKvl,ShiftEnb],'CornerLineBuffer');


    coreOut=topNet.addSignal(Corner.Type,'coreOut');
    isHarris=false;
    switch blockInfo.Method
    case 'FAST 5 of 8'
        FASTcoreNet=this.elabFASTCore(topNet,blockInfo,inRate);
        FASTcoreNet.addComment('FAST 5 of 8 Core');
        coreDelayBal=11;
        kernelDelay=1;
    case 'FAST 7 of 12'
        FASTcoreNet=this.elabFASTCore(topNet,blockInfo,inRate);
        FASTcoreNet.addComment('FAST 7 of 12 Core');
        coreDelayBal=11;
        kernelDelay=2;
    case 'FAST 9 of 16'
        FASTcoreNet=this.elabFASTCore(topNet,blockInfo,inRate);
        FASTcoreNet.addComment('FAST 9 of 16 Core');
        coreDelayBal=11;
        kernelDelay=3;
    otherwise
        FASTcoreNet=this.elabHarrisCore(topNet,blockInfo,inRate);
        FASTcoreNet.addComment('Harris Core');
        coreDelayBal=11;
        kernelDelay=1;
        isHarris=true;
    end

    if isHarris
        corehs=topNet.addSignal(ctrlType,'corehStartOut');
        corehe=topNet.addSignal(ctrlType,'corehEndOut');
        corevs=topNet.addSignal(ctrlType,'corevStartOut');
        coreve=topNet.addSignal(ctrlType,'corevEndOut');
        corevl=topNet.addSignal(ctrlType,'corevalidOut');
    end


    if blockInfo.numInputPorts==3
        if isHarris
            pirelab.instantiateNetwork(topNet,FASTcoreNet,[LMKData,ShiftEnb,LMKhs,LMKhe,LMKvs,LMKve,LMKvl,minCCast],...
            [coreOut,corehs,corehe,corevs,coreve,corevl],...
            'CornerCoreNet_inst');
            LMKhs=corehs;
            LMKhe=corehe;
            LMKvs=corevs;
            LMKve=coreve;
            LMKvl=corevl;
        else
            pirelab.instantiateNetwork(topNet,FASTcoreNet,[LMKData,ShiftEnb,minCCast],...
            coreOut,'CornerCoreNet_inst');
        end

    else
        if isHarris

            pirelab.instantiateNetwork(topNet,FASTcoreNet,[LMKData,ShiftEnb,LMKhs,LMKhe,LMKvs,LMKve,LMKvl],...
            [coreOut,corehs,corehe,corevs,coreve,corevl],...
            'CornerCoreNet_inst');
            LMKhs=corehs;
            LMKhe=corehe;
            LMKvs=corevs;
            LMKve=coreve;
            LMKvl=corevl;
        else
            pirelab.instantiateNetwork(topNet,FASTcoreNet,[LMKData,ShiftEnb],...
            coreOut,'CornerCoreNet_inst');
        end
    end







    totalDelay=coreDelayBal;
    nonKernelDelay=totalDelay-kernelDelay;

    if strcmpi(blockInfo.PaddingMethod,'None')
        if isHarris
            hsOKVDelay=LMKhs;
            heOKVDelay=LMKhe;
            vsOKVDelay=LMKvs;
            veOKVDelay=LMKve;
            vlOKVDelay=LMKvl;
        else
            validREG=topNet.addSignal(ctrlType,'validREG');

            hsOKDelay=topNet.addSignal(ctrlType,'hStartOutKernelDelay');
            pirelab.getIntDelayEnabledComp(topNet,LMKhs,hsOKDelay,ShiftEnb,kernelDelay);
            heOKDelay=topNet.addSignal(ctrlType,'hEndOutKernelDelay');
            pirelab.getIntDelayComp(topNet,LMKhe,heOKDelay,kernelDelay);

            pirelab.getUnitDelayEnabledResettableComp(topNet,LMKhe,validREG,LMKhe,heOKDelay,'validREG',0,'',true,'',-1,true);

            vsOKDelay=topNet.addSignal(ctrlType,'vStartOutKernelDelay');
            pirelab.getIntDelayEnabledComp(topNet,LMKvs,vsOKDelay,ShiftEnb,kernelDelay);
            veOKDelay=topNet.addSignal(ctrlType,'vEndOutKernelDelay');
            pirelab.getIntDelayComp(topNet,LMKve,veOKDelay,kernelDelay);
            vlOKDelay=topNet.addSignal(ctrlType,'validOutKernelDelay');
            validEnbDelay=topNet.addSignal(ctrlType,'validEnbDelay');
            pirelab.getIntDelayEnabledResettableComp(topNet,LMKvl,validEnbDelay,ShiftEnb,LMKhe,kernelDelay);

            pirelab.getLogicComp(topNet,[validEnbDelay,validREG],vlOKDelay,'or');

            processOREndLine=topNet.addSignal(ctrlType,'processOREndLine');
            pirelab.getLogicComp(topNet,[ShiftEnb,validREG],processOREndLine,'or');

            hsOKVDelay=topNet.addSignal(ctrlType,'hStartOutValidKernelDelay');
            pirelab.getLogicComp(topNet,[hsOKDelay,processOREndLine],hsOKVDelay,'and');
            heOKVDelay=topNet.addSignal(ctrlType,'hEndOutValidKernelDelay');
            pirelab.getLogicComp(topNet,[heOKDelay,processOREndLine],heOKVDelay,'and');
            vsOKVDelay=topNet.addSignal(ctrlType,'vStartOutValidKernelDelay');
            pirelab.getLogicComp(topNet,[vsOKDelay,processOREndLine],vsOKVDelay,'and');
            veOKVDelay=topNet.addSignal(ctrlType,'vEndOutValidKernelDelay');
            pirelab.getLogicComp(topNet,[veOKDelay,processOREndLine],veOKVDelay,'and');
            vlOKVDelay=topNet.addSignal(ctrlType,'validOutValidKernelDelay');
            pirelab.getLogicComp(topNet,[vlOKDelay,processOREndLine],vlOKVDelay,'and');
        end
    else
        if isHarris
            hsOKVDelay=LMKhs;
            heOKVDelay=LMKhe;
            vsOKVDelay=LMKvs;
            veOKVDelay=LMKve;
            vlOKVDelay=LMKvl;
        else

            hsOKDelay=topNet.addSignal(ctrlType,'hStartOutKernelDelay');
            pirelab.getIntDelayEnabledComp(topNet,LMKhs,hsOKDelay,ShiftEnb,kernelDelay);
            heOKDelay=topNet.addSignal(ctrlType,'hEndOutKernelDelay');
            pirelab.getIntDelayEnabledComp(topNet,LMKhe,heOKDelay,ShiftEnb,kernelDelay);
            vsOKDelay=topNet.addSignal(ctrlType,'vStartOutKernelDelay');
            pirelab.getIntDelayEnabledComp(topNet,LMKvs,vsOKDelay,ShiftEnb,kernelDelay);
            veOKDelay=topNet.addSignal(ctrlType,'vEndOutKernelDelay');
            pirelab.getIntDelayEnabledComp(topNet,LMKve,veOKDelay,ShiftEnb,kernelDelay);
            vlOKDelay=topNet.addSignal(ctrlType,'validOutKernelDelay');
            pirelab.getIntDelayEnabledComp(topNet,LMKvl,vlOKDelay,ShiftEnb,kernelDelay);

            hsOKVDelay=topNet.addSignal(ctrlType,'hStartOutValidKernelDelay');
            pirelab.getLogicComp(topNet,[hsOKDelay,ShiftEnb],hsOKVDelay,'and');
            heOKVDelay=topNet.addSignal(ctrlType,'hEndOutValidKernelDelay');
            pirelab.getLogicComp(topNet,[heOKDelay,ShiftEnb],heOKVDelay,'and');
            vsOKVDelay=topNet.addSignal(ctrlType,'vStartOutValidKernelDelay');
            pirelab.getLogicComp(topNet,[vsOKDelay,ShiftEnb],vsOKVDelay,'and');
            veOKVDelay=topNet.addSignal(ctrlType,'vEndOutValidKernelDelay');
            pirelab.getLogicComp(topNet,[veOKDelay,ShiftEnb],veOKVDelay,'and');
            vlOKVDelay=topNet.addSignal(ctrlType,'validOutValidKernelDelay');
            pirelab.getLogicComp(topNet,[vlOKDelay,ShiftEnb],vlOKVDelay,'and');
        end
    end


    hsODelay=topNet.addSignal(ctrlType,'hStartOutDelay');
    pirelab.getIntDelayComp(topNet,hsOKVDelay,hsODelay,nonKernelDelay);
    heODelay=topNet.addSignal(ctrlType,'hEndOutDelay');
    pirelab.getIntDelayComp(topNet,heOKVDelay,heODelay,nonKernelDelay);
    vsODelay=topNet.addSignal(ctrlType,'vStartOutDelay');
    pirelab.getIntDelayComp(topNet,vsOKVDelay,vsODelay,nonKernelDelay);
    veODelay=topNet.addSignal(ctrlType,'vEndOutDelay');
    pirelab.getIntDelayComp(topNet,veOKVDelay,veODelay,nonKernelDelay);
    vlODelay=topNet.addSignal(ctrlType,'validOutDelay');
    pirelab.getIntDelayComp(topNet,vlOKVDelay,vlODelay,nonKernelDelay);


    hStartNext=topNet.addSignal(ctrlType,'hsNext');
    pirelab.getLogicComp(topNet,[vlODelay,hsODelay],hStartNext,'and');
    hEndNext=topNet.addSignal(ctrlType,'heNext');
    pirelab.getLogicComp(topNet,[vlODelay,heODelay],hEndNext,'and');
    vStartNext=topNet.addSignal(ctrlType,'vsNext');
    pirelab.getLogicComp(topNet,[vlODelay,vsODelay],vStartNext,'and');
    vEndNext=topNet.addSignal(ctrlType,'veNext');
    pirelab.getLogicComp(topNet,[vlODelay,veODelay],vEndNext,'and');

    pirelab.getUnitDelayComp(topNet,hStartNext,hStartOut);
    pirelab.getUnitDelayComp(topNet,hEndNext,hEndOut);
    pirelab.getUnitDelayComp(topNet,vStartNext,vStartOut);
    pirelab.getUnitDelayComp(topNet,vEndNext,vEndOut);
    pirelab.getUnitDelayComp(topNet,vlODelay,validOut);

    zeroconst=topNet.addSignal(Corner.Type,'const_zero');
    pirelab.getConstComp(topNet,zeroconst,0);

    switchout1=topNet.addSignal(Corner.Type,'cornerNext');
    pirelab.getSwitchComp(topNet,[coreOut,zeroconst],switchout1,vlODelay,'','==',1);
    pirelab.getUnitDelayComp(topNet,switchout1,Corner);
