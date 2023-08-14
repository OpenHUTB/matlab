function treeNet=elabTree(this,topNet,blockInfo,dataRate)

    coreOrder=blockInfo.coreOrder;
    nMax=blockInfo.nMax;
    listLength=blockInfo.listLength;
    boolType=pir_boolean_t();
    decType=blockInfo.decType;
    betaVecType=pirelab.createPirArrayType(decType,[1,coreOrder]);
    intLlrType=blockInfo.intLlrType;
    intLlrVecType=pirelab.createPirArrayType(intLlrType,[1,coreOrder]);
    stageType=blockInfo.stageType;
    blockType=blockInfo.blockType;
    pathType=blockInfo.pathType;
    betaPathType=pirelab.createPirArrayType(pathType,[1,nMax]);
    decVecType=pirelab.createPirArrayType(decType,[1,listLength]);



    inportNames={'llrLowerIn','llrUpperIn','wrStage','wrBlock','lowerWrEn','upperWrEn',...
    'rdStage','rdBlock','betaIn','betaWrEn',...
    'alphaRdPath','betaRdPath','alphaWrPath','betaWrPath','nSub1','mode'...
    };
    inTypes=[intLlrVecType,intLlrVecType,stageType,blockType,boolType,boolType,...
    stageType,blockType,decVecType,boolType,...
    pathType,betaPathType,pathType,pathType,stageType,boolType...
    ];
    indataRates=dataRate*ones(1,length(inportNames));

    outportNames={'llrLowerOut','llrUpperOut','betaOut'};
    outTypes=[intLlrVecType,intLlrVecType,betaVecType];

    treeNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','TreeMemory',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );

    llrLowerIn=treeNet.PirInputSignals(1);
    llrUpperIn=treeNet.PirInputSignals(2);
    wrStage=treeNet.PirInputSignals(3);
    wrBlock=treeNet.PirInputSignals(4);
    lowerWrEn=treeNet.PirInputSignals(5);
    upperWrEn=treeNet.PirInputSignals(6);
    rdStage=treeNet.PirInputSignals(7);
    rdBlock=treeNet.PirInputSignals(8);
    betaIn=treeNet.PirInputSignals(9);
    betaWrEn=treeNet.PirInputSignals(10);
    alphaRdPath=treeNet.PirInputSignals(11);
    betaRdPath=treeNet.PirInputSignals(12);
    alphaWrPath=treeNet.PirInputSignals(13);
    betaWrPath=treeNet.PirInputSignals(14);
    nSub1=treeNet.PirInputSignals(15);
    mode=treeNet.PirInputSignals(16);

    llrLowerOut=treeNet.PirOutputSignals(1);
    llrUpperOut=treeNet.PirOutputSignals(2);
    betaOut=treeNet.PirOutputSignals(3);


    stageOffsets=zeros(nMax,1);
    for ii=1:nMax-1
        stageOffsets(ii+1)=stageOffsets(ii)...
        +ceil(2^(ii)/coreOrder/2);
    end
    stageLutType=pir_ufixpt_t(nextpow2(max(stageOffsets+1)),0);
    blockOffsetType=pir_ufixpt_t(max(stageLutType.WordLength,stageType.WordLength)+1,0);
    addrType=pir_ufixpt_t(blockOffsetType.WordLength+pathType.WordLength,0);


    wrStageOffset=treeNet.addSignal(stageLutType,'wrStageOffset');
    pirelab.getLookupComp(treeNet,wrStage,wrStageOffset,0:nMax-1,stageOffsets);

    wrBlockOffset=treeNet.addSignal(blockOffsetType,'wrBlockOffset');
    pirelab.getAddComp(treeNet,[wrStageOffset,wrBlock],wrBlockOffset);

    wrAddr=treeNet.addSignal(addrType,'wrAddr');
    pirelab.getBitConcatComp(treeNet,[wrBlockOffset,alphaWrPath],wrAddr);


    rdStageOffset=treeNet.addSignal(stageLutType,'rdStageOffset');
    pirelab.getLookupComp(treeNet,rdStage,rdStageOffset,0:nMax-1,stageOffsets);

    rdBlockOffset=treeNet.addSignal(blockOffsetType,'rdBlockOffset');
    pirelab.getAddComp(treeNet,[rdStageOffset,rdBlock],rdBlockOffset);

    rdChannel=treeNet.addSignal(boolType,'rdChannel');
    pirelab.getRelOpComp(treeNet,[rdStage,nSub1],rdChannel,'==');

    pathZero=treeNet.addSignal(pathType,'pathZero');
    pathZero.SimulinkRate=dataRate;
    pirelab.getConstComp(treeNet,pathZero,0);

    alphaWrPathSel=treeNet.addSignal(pathType,'alphaWrPathSel');
    pirelab.getMultiPortSwitchComp(treeNet,[rdChannel,alphaRdPath,pathZero],alphaWrPathSel,1);

    rdAddr=treeNet.addSignal(addrType,'rdAddr');
    pirelab.getBitConcatComp(treeNet,[rdBlockOffset,alphaWrPathSel],rdAddr);


    llrLowerDemux=pirelab.demuxSignal(treeNet,llrLowerIn);
    llrUpperDemux=pirelab.demuxSignal(treeNet,llrUpperIn);

    WL=intLlrType.WordLength;
    decatLlrType=pir_ufixpt_t(WL,0);

    storedCount=0;
    ii=1;

    while storedCount~=coreOrder

        toStore=min(floor(128/WL),coreOrder-storedCount);

        dType=pir_ufixpt_t(toStore*WL,0);

        llrLowerConcat(ii)=treeNet.addSignal(dType,['llrLowerConcat_',num2str(ii-1)]);%#ok
        llrUpperConcat(ii)=treeNet.addSignal(dType,['llrUpperConcat_',num2str(ii-1)]);%#ok
        pirelab.getBitConcatComp(treeNet,llrLowerDemux(storedCount+1:storedCount+toStore),llrLowerConcat(ii));
        pirelab.getBitConcatComp(treeNet,llrUpperDemux(storedCount+1:storedCount+toStore),llrUpperConcat(ii));

        lowerDout(ii)=treeNet.addSignal(dType,['lowerDout_',num2str(ii-1)]);%#ok
        upperDout(ii)=treeNet.addSignal(dType,['upperDout_',num2str(ii-1)]);%#ok
        pirelab.getSimpleDualPortRamComp(treeNet,[llrLowerConcat(ii),wrAddr,lowerWrEn,rdAddr],lowerDout(ii));
        pirelab.getSimpleDualPortRamComp(treeNet,[llrUpperConcat(ii),wrAddr,upperWrEn,rdAddr],upperDout(ii));

        for jj=1:toStore
            msb=(toStore-jj)*WL+WL-1;
            lsb=(toStore-jj)*WL;

            lowerDoutSlice(storedCount+jj)=treeNet.addSignal(decatLlrType,['lowerDoutSlice_',storedCount+jj]);%#ok
            upperDoutSlice(storedCount+jj)=treeNet.addSignal(decatLlrType,['upperDoutSlice_',storedCount+jj]);%#ok
            pirelab.getBitSliceComp(treeNet,lowerDout(ii),lowerDoutSlice(storedCount+jj),msb,lsb);
            pirelab.getBitSliceComp(treeNet,upperDout(ii),upperDoutSlice(storedCount+jj),msb,lsb);

            lowerDoutSliceDTC(storedCount+jj)=treeNet.addSignal(intLlrType,['lowerDoutSliceDTC_',ii]);%#ok
            upperDoutSliceDTC(storedCount+jj)=treeNet.addSignal(intLlrType,['upperDoutSliceDTC_',ii]);%#ok
            pirelab.getDTCComp(treeNet,lowerDoutSlice(storedCount+jj),lowerDoutSliceDTC(storedCount+jj),'Floor','Wrap','SI');
            pirelab.getDTCComp(treeNet,upperDoutSlice(storedCount+jj),upperDoutSliceDTC(storedCount+jj),'Floor','Wrap','SI');
        end

        storedCount=storedCount+toStore;
        ii=ii+1;
    end

    lowerDoutDecat=treeNet.addSignal(intLlrVecType,'lowerDoutDecat');
    upperDoutDecat=treeNet.addSignal(intLlrVecType,'upperDoutDecat');
    pirelab.getConcatenateComp(treeNet,lowerDoutSliceDTC,lowerDoutDecat,'Multidimensional array',2);
    pirelab.getConcatenateComp(treeNet,upperDoutSliceDTC,upperDoutDecat,'Multidimensional array',2);


    rdWrEq=treeNet.addSignal(boolType,'rdWrEq');
    pirelab.getRelOpComp(treeNet,[wrAddr,rdAddr],rdWrEq,'==');

    bypassLower=treeNet.addSignal(boolType,'bypassLower');
    bypassUpper=treeNet.addSignal(boolType,'bypassUpper');
    pirelab.getLogicComp(treeNet,[rdWrEq,lowerWrEn],bypassLower,'and');
    pirelab.getLogicComp(treeNet,[rdWrEq,upperWrEn],bypassUpper,'and');


    bypassLower_reg=treeNet.addSignal(boolType,'bypassLower_reg');
    bypassUpper_reg=treeNet.addSignal(boolType,'bypassUpper_reg');
    llrLowerIn_reg=treeNet.addSignal(intLlrVecType,'llrLowerIn_reg');
    llrUpperIn_reg=treeNet.addSignal(intLlrVecType,'llrUpperIn_reg');
    pirelab.getUnitDelayComp(treeNet,bypassLower,bypassLower_reg);
    pirelab.getUnitDelayComp(treeNet,bypassUpper,bypassUpper_reg);
    pirelab.getUnitDelayComp(treeNet,llrLowerIn,llrLowerIn_reg);
    pirelab.getUnitDelayComp(treeNet,llrUpperIn,llrUpperIn_reg);

    pirelab.getMultiPortSwitchComp(treeNet,[bypassLower_reg,lowerDoutDecat,llrLowerIn_reg],llrLowerOut,1);
    pirelab.getMultiPortSwitchComp(treeNet,[bypassUpper_reg,upperDoutDecat,llrUpperIn_reg],llrUpperOut,1);




    betaLatched=treeNet.addSignal(decVecType,'betaLatched');
    pirelab.getUnitDelayEnabledComp(treeNet,betaIn,betaLatched,betaWrEn);

    betaWrPath_reg=treeNet.addSignal(pathType,'betaWrPath_reg');
    rdStage_reg=treeNet.addSignal(stageType,'rdStage_reg');
    pirelab.getUnitDelayComp(treeNet,betaWrPath,betaWrPath_reg);
    pirelab.getUnitDelayComp(treeNet,rdStage,rdStage_reg);

    betaSel=treeNet.addSignal(decType,'betaSel');
    pirelab.getMultiPortSwitchComp(treeNet,[betaWrPath_reg,betaLatched],betaSel,0);

    rdBlock_reg=treeNet.addSignal(blockType,'rdBlock_reg');
    pirelab.getUnitDelayComp(treeNet,rdBlock,rdBlock_reg);


    for ii=1:nMax
        stageEn(ii)=treeNet.addSignal(boolType,['stageEn_',num2str(ii-1)]);%#ok
        pirelab.getCompareToValueComp(treeNet,rdStage_reg,stageEn(ii),'==',ii-1);

        stageWr(ii)=treeNet.addSignal(boolType,['stageWr_',num2str(ii-1)]);%#ok
        pirelab.getLogicComp(treeNet,[stageEn(ii),mode],stageWr(ii),'and');

        if ii~=nMax
            betaRdPathSel(ii)=treeNet.addSignal(pathType,['betaRdPathSel_',num2str(ii-1)]);%#ok
            pirelab.getSelectorComp(treeNet,betaRdPath,betaRdPathSel(ii),'one-based',...
            {'Index vector (dialog)','Index vector (dialog)'},...
            {1,ii},...
            {'Inherit from "Index"','Inherit from "Index"'},'2');
        end
    end


    betaLOut(1)=treeNet.addSignal(decType,'betaLOut_0');
    betaROut(1)=treeNet.addSignal(decType,'betaROut_0');
    betaSzMatch(1)=treeNet.addSignal(betaVecType,'betaSzMatch_0');

    pirelab.getWireComp(treeNet,betaSel,betaROut(1));
    if betaWrPath_reg.Type.WordLength==1
        addRamWorkAround(treeNet,[betaSel,betaWrPath_reg,stageWr(1),betaRdPathSel(1)],betaLOut(1),'stage_0',dataRate);
    else
        pirelab.getSimpleDualPortRamComp(treeNet,[betaSel,betaWrPath_reg,stageWr(1),betaRdPathSel(1)],betaLOut(1),'stage_0');
    end
    szMatchType=pirelab.createPirArrayType(decType,[1,coreOrder-1]);
    szMatchConst(1)=treeNet.addSignal(szMatchType,'szMatchConst_0');
    szMatchConst(1).SimulinkRate=dataRate;
    pirelab.getConstComp(treeNet,szMatchConst(1),0);

    pirelab.getConcatenateComp(treeNet,[betaROut(1),szMatchConst(1)],betaSzMatch(1),'Multidimensional array',2);

    betaPassType=pir_ufixpt_t(1,0);

    doutSliceIdx=0;

    for ii=2:nMax-1
        betaLIn=betaLOut(ii-1);
        betaRIn=betaROut(ii-1);

        stageOutSize=min(2^(ii-1),coreOrder);

        if ii<=log2(coreOrder)+1
            stageCatSize=stageOutSize;
        else
            stageCatSize=stageOutSize*2;
        end

        betaOutType=pirelab.createPirArrayType(decType,[1,stageOutSize]);
        betaCatType=pirelab.createPirArrayType(decType,[1,stageCatSize]);

        betaLOut(ii)=treeNet.addSignal(betaOutType,['betaLOut_',num2str(ii-1)]);%#ok
        betaROut(ii)=treeNet.addSignal(betaOutType,['betaROut_',num2str(ii-1)]);%#ok

        betaXor(ii-1)=treeNet.addSignal(betaLIn.Type,['betaXor_',num2str(ii-2)]);%#ok
        pirelab.getBitwiseOpComp(treeNet,[betaLIn,betaRIn],betaXor(ii-1),'xor');

        betaConcat(ii-1)=treeNet.addSignal(betaCatType,['betaConcat_',num2str(ii-2)]);%#ok
        pirelab.getConcatenateComp(treeNet,[betaXor(ii-1),betaRIn],betaConcat(ii-1),'Multidimensional array',2);

        betaDType=pir_ufixpt_t(stageCatSize,0);
        betaDin(ii-1)=treeNet.addSignal(betaDType,['betaDin_',num2str(ii-2)]);%#ok
        pirelab.getBitConcatComp(treeNet,betaConcat(ii-1),betaDin(ii-1));


        if ii<=log2(coreOrder)+2
            betaWrAddr(ii-1)=treeNet.addSignal(pathType,['betaWrAddr_',num2str(ii-2)]);%#ok
            betaRdAddr(ii-1)=treeNet.addSignal(pathType,['betaRdAddr_',num2str(ii-2)]);%#ok
            pirelab.getWireComp(treeNet,betaWrPath_reg,betaWrAddr(ii-1));
            pirelab.getWireComp(treeNet,betaRdPathSel(ii),betaRdAddr(ii-1));
        else
            idx=ii-(log2(coreOrder)+2);
            rdBlkSlcType=pir_ufixpt_t(idx,0);
            rdBlockSlice(idx)=treeNet.addSignal(rdBlkSlcType,['rdBlockSlice_',num2str(idx-1)]);%#ok
            rdBlockSlice_reg(idx)=treeNet.addSignal(rdBlkSlcType,['rdBlockSlice_',num2str(idx-1)]);%#ok
            pirelab.getBitSliceComp(treeNet,rdBlock,rdBlockSlice(idx),idx-1,0);
            pirelab.getBitSliceComp(treeNet,rdBlock_reg,rdBlockSlice_reg(idx),idx-1,0);

            betaAddrConcatType=pir_ufixpt_t(pathType.WordLength+idx,0);
            betaWrAddr(ii-1)=treeNet.addSignal(betaAddrConcatType,['betaWrAddr_',num2str(ii-2)]);%#ok
            betaRdAddr(ii-1)=treeNet.addSignal(betaAddrConcatType,['betaRdAddr_',num2str(ii-2)]);%#ok

            pirelab.getBitConcatComp(treeNet,[rdBlockSlice_reg(idx),betaWrPath_reg],betaWrAddr(ii-1));
            pirelab.getBitConcatComp(treeNet,[rdBlockSlice(idx),betaRdPathSel(ii)],betaRdAddr(ii-1));
        end

        betaDout(ii-1)=treeNet.addSignal(betaDType,['betaDout_',num2str(ii-2)]);%#ok
        if betaWrAddr(ii-1).Type.WordLength==1
            addRamWorkAround(treeNet,[betaDin(ii-1),betaWrAddr(ii-1),stageWr(ii),betaRdAddr(ii-1)],betaDout(ii-1),['stage_',num2str(ii-1)],dataRate)
        else
            pirelab.getSimpleDualPortRamComp(treeNet,[betaDin(ii-1),betaWrAddr(ii-1),stageWr(ii),betaRdAddr(ii-1)],betaDout(ii-1),['stage_',num2str(ii-1)]);
        end


        for j=1:stageCatSize
            doutSlice(doutSliceIdx+j)=treeNet.addSignal(decType,'doutSlice');%#ok
            pirelab.getBitSliceComp(treeNet,betaDout(ii-1),doutSlice(doutSliceIdx+j),stageCatSize-j,stageCatSize-j);
        end

        betaLDecat(ii-1)=treeNet.addSignal(betaCatType,['betaLDecat',num2str(ii-2)]);%#ok
        pirelab.getConcatenateComp(treeNet,doutSlice(doutSliceIdx+1:doutSliceIdx+stageCatSize),betaLDecat(ii-1),'Multidimensional array',2);
        doutSliceIdx=doutSliceIdx+stageCatSize;


        if ii<=log2(coreOrder)+1

            pirelab.getWireComp(treeNet,betaLDecat(ii-1),betaLOut(ii));

            pirelab.getWireComp(treeNet,betaConcat(ii-1),betaROut(ii));
        else
            idx=ii-(log2(coreOrder)+1);
            betaPass(idx)=treeNet.addSignal(betaPassType,['betaPass_',num2str(idx-1)]);%#ok


            betaLLower(idx)=treeNet.addSignal(betaOutType,['betaLLower_',num2str(idx-1)]);%#ok
            betaLUpper(idx)=treeNet.addSignal(betaOutType,['betaLUpper_',num2str(idx-1)]);%#ok
            pirelab.getSelectorComp(treeNet,betaLDecat(ii-1),betaLLower(idx),'one-based',...
            {'Index vector (dialog)','Index vector (dialog)'},...
            {1,1:coreOrder},...
            {'Inherit from "Index"','Inherit from "Index"'},'2');
            pirelab.getSelectorComp(treeNet,betaLDecat(ii-1),betaLUpper(idx),'one-based',...
            {'Index vector (dialog)','Index vector (dialog)'},...
            {1,coreOrder+1:coreOrder*2},...
            {'Inherit from "Index"','Inherit from "Index"'},'2');
            betaLUpper_reg(idx)=treeNet.addSignal(betaOutType,['betaLUpper_reg',num2str(idx-1)]);%#ok
            pirelab.getIntDelayComp(treeNet,betaLUpper(idx),betaLUpper_reg(idx),2.^(idx-1));
            pirelab.getMultiPortSwitchComp(treeNet,[betaPass(idx),betaLLower(idx),betaLUpper_reg(idx)],betaLOut(ii),1);


            pirelab.getBitSliceComp(treeNet,rdBlock_reg,betaPass(idx),idx-1,idx-1);

            betaRIn_reg(idx)=treeNet.addSignal(betaOutType,['betaRIn_reg_',num2str(idx-1)]);%#ok
            pirelab.getIntDelayComp(treeNet,betaRIn,betaRIn_reg(idx),2.^(idx-1));
            pirelab.getMultiPortSwitchComp(treeNet,[betaPass(idx),betaXor(ii-1),betaRIn_reg(idx)],betaROut(ii),1);
        end

        betaSzMatch(ii)=treeNet.addSignal(betaVecType,['betaSizeMatch_',num2str(ii-1)]);%#ok

        if ii<=log2(coreOrder)
            szMatchType=pirelab.createPirArrayType(decType,[1,coreOrder-stageOutSize]);
            szMatchConst(ii)=treeNet.addSignal(szMatchType,['szMatchConst_',num2str(ii-2)]);%#ok
            szMatchConst(ii).SimulinkRate=dataRate;%#ok
            pirelab.getConstComp(treeNet,szMatchConst(ii),0);

            pirelab.getConcatenateComp(treeNet,[betaROut(ii),szMatchConst(ii)],betaSzMatch(ii),'Multidimensional array',2);
        else
            pirelab.getWireComp(treeNet,betaROut(ii),betaSzMatch(ii));
        end
    end


    stageOutSize=min(2^(ii-1),coreOrder);
    idx=nMax-(log2(coreOrder)+1);

    betaOutType=pirelab.createPirArrayType(decType,[1,stageOutSize]);

    betaLIn=betaLOut(nMax-1);
    betaRIn=betaROut(nMax-1);

    betaPass(idx)=treeNet.addSignal(betaPassType,['betaPass_',num2str(idx-1)]);
    pirelab.getBitSliceComp(treeNet,rdBlock_reg,betaPass(idx),idx-1,idx-1);

    betaXor(nMax-1)=treeNet.addSignal(betaLIn.Type,['betaXor_',num2str(nMax-2)]);
    pirelab.getBitwiseOpComp(treeNet,[betaLIn,betaRIn],betaXor(nMax-1),'xor');

    betaRIn_reg(idx)=treeNet.addSignal(betaOutType,['betaRIn_reg_',num2str(idx-1)]);
    pirelab.getIntDelayComp(treeNet,betaRIn,betaRIn_reg(idx),2.^(idx-1));

    betaROut(nMax)=treeNet.addSignal(betaOutType,['betaROut_',num2str(nMax-1)]);
    pirelab.getMultiPortSwitchComp(treeNet,[betaPass(idx),betaXor(nMax-1),betaRIn_reg(idx)],betaROut(nMax),1);
    betaSzMatch(nMax)=treeNet.addSignal(betaVecType,['betaSzMatch_',num2str(nMax-1)]);
    pirelab.getWireComp(treeNet,betaROut(nMax),betaSzMatch(nMax));


    pirelab.getMultiPortSwitchComp(treeNet,[rdStage_reg,betaSzMatch],betaOut,1);
end

function addRamWorkAround(treeNet,insignals,outsignals,compName,dataRate)
    dType=insignals(1).Type;

    addrType=pir_ufixpt_t(1,0);
    boolType=pir_boolean_t;

    inportnames{1}='din';
    inportnames{2}='wr_addr';
    inportnames{3}='wr_en';
    inportnames{4}='rd_addr';

    outportnames{1}='dout';


    ramNet=pirelab.createNewNetwork(...
    'Network',treeNet,...
    'Name','ramNet',...
    'InportNames',inportnames,...
    'InportTypes',[dType,addrType,boolType,addrType],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate],...
    'OutportNames',outportnames,...
    'OutportTypes',dType...
    );

    dIn=ramNet.PirInputSignals(1);
    wrAddr=ramNet.PirInputSignals(2);
    wrEn=ramNet.PirInputSignals(3);
    rdAddr=ramNet.PirInputSignals(4);

    dOut=ramNet.PirOutputSignals(1);

    for i=1:2
        addrComp(i)=ramNet.addSignal(boolType,['addrComp_',num2str(i-1)]);%#ok
        pirelab.getCompareToValueComp(ramNet,wrAddr,addrComp(i),'==',i-1);

        wr(i)=ramNet.addSignal(boolType,['wr_',num2str(i-1)]);%#ok
        pirelab.getLogicComp(ramNet,[addrComp(i),wrEn],wr(i),'and');

        ramData(i)=ramNet.addSignal(dType,['ramData_',num2str(i-1)]);%#ok
        pirelab.getUnitDelayEnabledComp(ramNet,dIn,ramData(i),wr(i));
    end

    ramDataSel=ramNet.addSignal(dType,'ramDataSel');
    pirelab.getMultiPortSwitchComp(ramNet,[rdAddr,ramData],ramDataSel,1);

    pirelab.getUnitDelayComp(ramNet,ramDataSel,dOut);

    pirelab.instantiateNetwork(treeNet,ramNet,insignals,outsignals,compName);
end