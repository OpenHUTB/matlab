function pathNet=elabPathMem(this,topNet,blockInfo,dataRate)
    coreOrder=blockInfo.coreOrder;
    nMax=blockInfo.nMax;
    listLength=blockInfo.listLength;
    dupLim=blockInfo.dupLim;
    boolType=pir_boolean_t();
    boolVecType=pirelab.createPirArrayType(boolType,[1,listLength]);

    concatBetaType=blockInfo.concatBetaType;
    pathType=blockInfo.pathType;
    contPathsType=pirelab.createPirArrayType(pathType,[1,listLength]);
    decType=blockInfo.decType;
    decVecType=pirelab.createPirArrayType(decType,[1,listLength]);
    KType=blockInfo.KType;





    ptrType=pir_ufixpt_t(KType.WordLength+pathType.WordLength,0);
    ptrAddrType=pir_ufixpt_t(3,0);
    if listLength==2


        numPtrs=1;
        ptrVecType=ptrType;
        ptrAddrVecType=ptrAddrType;
        ptrBoolVecType=boolType;
        KVecType=KType;
        pathVecType=pathType;
    else
        numPtrs=listLength;
        ptrVecType=pirelab.createPirArrayType(ptrType,[1,listLength]);
        ptrAddrVecType=pirelab.createPirArrayType(ptrAddrType,[1,listLength]);
        ptrBoolVecType=pirelab.createPirArrayType(boolType,[1,listLength]);
        KVecType=pirelab.createPirArrayType(KType,[1,listLength]);
        pathVecType=pirelab.createPirArrayType(pathType,[1,listLength]);
    end


    inportNames={'hardDecs','pathWrEn','contPaths','pathRdAddr','rdPath','rstRdCnt','rstWrCnt'};
    inTypes=[decVecType,boolType,contPathsType,KType,boolType,boolType,boolType];
    indataRates=dataRate*ones(1,length(inportNames));

    outportNames={'canPaths','copyEn'};
    outTypes=[decVecType,boolType];

    pathNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','PathMem',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );

    hardDecs=pathNet.PirInputSignals(1);
    pathWrEn=pathNet.PirInputSignals(2);
    contPaths=pathNet.PirInputSignals(3);
    pathRdAddr=pathNet.PirInputSignals(4);
    rdPath=pathNet.PirInputSignals(5);
    rstRdCnt=pathNet.PirInputSignals(6);
    rstWrCnt=pathNet.PirInputSignals(7);

    canPaths=pathNet.PirOutputSignals(1);
    copyEn=pathNet.PirOutputSignals(2);



    pathWrAddr=pathNet.addSignal(KType,'pathWrAddr');
    pirelab.getCounterComp(pathNet,[rstWrCnt,pathWrEn],pathWrAddr,'Free running',0,1,[],1,0,1,0);



    hardDecsFlip=pathNet.addSignal(decVecType,'hardDecsFlip');
    pirelab.getSelectorComp(pathNet,hardDecs,hardDecsFlip,'one-based',...
    {'Index vector (dialog)','Index vector (dialog)'},...
    {1,listLength:-1:1},...
    {'Inherit from "Index"','Inherit from "Index"'},'2');
    hardDecsCat=pathNet.addSignal(concatBetaType,'hardDecsCat');
    pirelab.getBitConcatComp(pathNet,hardDecsFlip,hardDecsCat);

    hardDecsCat_reg=pathNet.addSignal(concatBetaType,'hardDecsCat_reg');
    pathWrAddr_reg=pathNet.addSignal(KType,'pathWrAddr_reg');
    pathWrEn_reg=pathNet.addSignal(boolType,'pathWrEn_reg');
    pathRdAddr_reg=pathNet.addSignal(KType,'pathRdAddr_reg');
    pirelab.getUnitDelayComp(pathNet,hardDecsCat,hardDecsCat_reg);
    pirelab.getUnitDelayComp(pathNet,pathWrAddr,pathWrAddr_reg);
    pirelab.getUnitDelayComp(pathNet,pathWrEn,pathWrEn_reg);
    pirelab.getUnitDelayComp(pathNet,pathRdAddr,pathRdAddr_reg);

    pathDout=pathNet.addSignal(concatBetaType,'pathDout');
    pirelab.getSimpleDualPortRamComp(pathNet,[hardDecsCat_reg,pathWrAddr_reg,pathWrEn_reg,pathRdAddr_reg],pathDout);

    for ii=1:listLength
        hardDecsDecat(ii)=pathNet.addSignal(decType,['hardDecsDecat_',num2str(ii-1)]);%#ok
        pirelab.getBitSliceComp(pathNet,pathDout,hardDecsDecat(ii),ii-1,ii-1);

        hardDecsDecat_reg(ii)=pathNet.addSignal(decType,['hardDecsDecat_reg_',num2str(ii-1)]);%#ok
        pirelab.getUnitDelayComp(pathNet,hardDecsDecat(ii),hardDecsDecat_reg(ii));
    end





    decsToUpdate=pathNet.addSignal(boolType,'decsToUpdate');
    pirelab.getCompareToValueComp(pathNet,pathWrAddr,decsToUpdate,'~=',0);

    updatePtrs=pathNet.addSignal(boolType,'updatePtrs');
    pirelab.getLogicComp(pathNet,[pathWrEn,decsToUpdate],updatePtrs,'and');

    contPaths_reg=pathNet.addSignal(contPathsType,'contPaths_reg');
    pirelab.getUnitDelayComp(pathNet,contPaths,contPaths_reg);

    pathOW=pathNet.addSignal(boolVecType,'pathOW');
    pirelab.getCompareToValueComp(pathNet,contPaths_reg,pathOW,'~=',0:listLength-1);

    rdPath_reg=pathNet.addSignal(boolType,'rdPath_reg');
    pirelab.getUnitDelayComp(pathNet,rdPath,rdPath_reg);

    virtPtrRdAddr=pathNet.addSignal(ptrAddrVecType,'virtPtrRdAddr');

    if listLength==2
        anyOW=pathNet.addSignal(boolType,'anyOW');
        pirelab.getBitwiseOpComp(pathNet,pathOW,anyOW,'or');

        ptrWrEn=pathNet.addSignal(boolType,'ptrWrEn');
        pirelab.getLogicComp(pathNet,[updatePtrs,anyOW],ptrWrEn,'and');

        dupPathId=pirelab.demuxSignal(pathNet,pathOW);


        dupPathId_reg=pathNet.addSignal(pathType,'dupPathId_reg');
        ptrWrEn_reg=pathNet.addSignal(boolType,'ptrWrEn_reg');
        rstWrCnt_reg=pathNet.addSignal(boolType,'rstWrCnt_reg');
        pirelab.getUnitDelayComp(pathNet,dupPathId(1),dupPathId_reg);
        pirelab.getUnitDelayComp(pathNet,ptrWrEn,ptrWrEn_reg);
        pirelab.getUnitDelayComp(pathNet,rstWrCnt,rstWrCnt_reg);



        ptrDin=pathNet.addSignal(ptrType,'ptrDin');
        pirelab.getBitConcatComp(pathNet,[pathWrAddr_reg,dupPathId_reg],ptrDin);





        nextPtrWrAddr=pathNet.addSignal(ptrAddrVecType,'nextPtrWrAddr');

        prevPtr=pathNet.addSignal(pathType,'prevPtr');

        ptrsNEq=pathNet.addSignal(boolType,'ptrsNEq');
        pirelab.getRelOpComp(pathNet,[prevPtr,dupPathId_reg],ptrsNEq,'~=');

        firstPtr=pathNet.addSignal(boolType,'firstPtr');
        pirelab.getCompareToValueComp(pathNet,nextPtrWrAddr,firstPtr,'==',0);

        updatePtr=pathNet.addSignal(boolType,'updatePtr');
        pirelab.getLogicComp(pathNet,[ptrsNEq,firstPtr],updatePtr,'or');

        ptrCntInc=pathNet.addSignal(boolType,'incPtrCnt');
        pirelab.getLogicComp(pathNet,[ptrWrEn_reg,updatePtr],ptrCntInc,'and');

        pirelab.getCounterComp(pathNet,[rstWrCnt_reg,ptrCntInc],nextPtrWrAddr,'Free running',0,1,[],1,0,1,0);

        pirelab.getUnitDelayEnabledComp(pathNet,dupPathId_reg,prevPtr,ptrCntInc,'prevPtrReg','','',false,'',-1,true);


        curPtrWrAddr=pathNet.addSignal(ptrAddrVecType,'curPtrWrAddr');
        pirelab.getDecrementRWV(pathNet,nextPtrWrAddr,curPtrWrAddr);

        ptrWrAddr=pathNet.addSignal(ptrAddrVecType,'ptrWrAddr');
        pirelab.getMultiPortSwitchComp(pathNet,[updatePtr,curPtrWrAddr,nextPtrWrAddr],ptrWrAddr,1);

        ptrDout=pathNet.addSignal(ptrVecType,'ptrDout');
        pirelab.getSimpleDualPortRamComp(pathNet,[ptrDin,ptrWrAddr,ptrWrEn_reg,virtPtrRdAddr],ptrDout);
    else
        ptrWrEn=pathNet.addSignal(boolType,'ptrWrEn');
        pirelab.getWireComp(pathNet,updatePtrs,ptrWrEn,'and');

        ptrCntWrEn=pathNet.addSignal(ptrBoolVecType,'pathPtrWrEn');
        pirelab.getLogicComp(pathNet,[updatePtrs,pathOW],ptrCntWrEn,'and');

        pathIdxConst=pathNet.addSignal(contPathsType,'pathIdxConst');
        pathIdxConst.SimulinkRate=dataRate;
        pirelab.getConstComp(pathNet,pathIdxConst,0:listLength-1);

        ptrCntRdAddr=pathNet.addSignal(contPathsType,'ptrCntRdAddr');
        pirelab.getMultiPortSwitchComp(pathNet,[updatePtrs,pathIdxConst,contPaths_reg],ptrCntRdAddr,1);

        ptrCntOut=pathNet.addSignal(ptrAddrVecType,'ptrCntOut');

        ptrCntInc=pathNet.addSignal(ptrAddrVecType,'ptrCntInc');
        pirelab.getIncrementRWV(pathNet,ptrCntOut,ptrCntInc);

        ptrCntWrEnDemux=pirelab.demuxSignal(pathNet,ptrCntWrEn);
        ptrCntIncDemux=pirelab.demuxSignal(pathNet,ptrCntInc);

        for ii=1:listLength
            ptrCnt(ii)=pathNet.addSignal(ptrAddrType,['ptrCnt_',num2str(ii-1)]);%#ok
            pirelab.getUnitDelayEnabledResettableComp(pathNet,ptrCntIncDemux(ii),ptrCnt(ii),ptrCntWrEnDemux(ii),rstWrCnt);
        end

        pirelab.getMultiPortSwitchComp(pathNet,[ptrCntRdAddr,ptrCnt],ptrCntOut,2);

        contPaths_reg_reg=pathNet.addSignal(contPathsType,'contPaths_reg_reg');
        nextPtrWrAddr=pathNet.addSignal(ptrAddrVecType,'nextPtrWrAddr');
        ptrWrEn_reg=pathNet.addSignal(boolType,'ptrWrEn_reg');
        pirelab.getUnitDelayComp(pathNet,contPaths_reg,contPaths_reg_reg);
        pirelab.getUnitDelayComp(pathNet,ptrCntOut,nextPtrWrAddr);
        pirelab.getUnitDelayComp(pathNet,ptrWrEn,ptrWrEn_reg);

        contPathsDemux=pirelab.demuxSignal(pathNet,contPaths_reg_reg);

        ptrVecType=pirelab.createPirArrayType(ptrType,[1,listLength]);
        ptrDin=pathNet.addSignal(ptrVecType,'ptrDin');
        pirelab.getBitConcatComp(pathNet,[pathWrAddr_reg,contPaths_reg_reg],ptrDin);
        ptrDinDemux=pirelab.demuxSignal(pathNet,ptrDin);

        for ii=1:dupLim
            wrNewPtr(ii)=pathNet.addSignal(boolVecType,['wrNewPtr_',num2str(ii-1)]);%#ok
            pirelab.getCompareToValueComp(pathNet,nextPtrWrAddr,wrNewPtr(ii),'==',ii-1);

            wrNewPtrDemux(ii,1:listLength)=pirelab.demuxSignal(pathNet,wrNewPtr(ii));%#ok

            for jj=1:listLength
                pathPtr(ii,jj)=pathNet.addSignal(ptrType,['pathPtr_',num2str(ii-1),'_',num2str(jj-1)]);%#ok
            end
            for jj=1:listLength
                copiedPtr(ii,jj)=pathNet.addSignal(ptrType,['copiedPtr_',num2str(ii-1),'_',num2str(jj-1)]);%#ok
                pirelab.getMultiPortSwitchComp(pathNet,[contPathsDemux(jj),pathPtr(ii,:)],copiedPtr(ii,jj),1);

                newPtr(ii,jj)=pathNet.addSignal(ptrType,['newPtr_',num2str(ii-1),'_',num2str(jj-1)]);%#ok
                pirelab.getMultiPortSwitchComp(pathNet,[wrNewPtrDemux(ii,jj),copiedPtr(ii,jj),ptrDinDemux(jj)],newPtr(ii,jj),1);

                pirelab.getUnitDelayEnabledComp(pathNet,newPtr(ii,jj),pathPtr(ii,jj),ptrWrEn_reg,['ptrReg_',num2str(ii),'_',num2str(jj)],'','',false,'',-1,true);
            end

            pathPtrCat(ii)=pathNet.addSignal(ptrVecType,['pathPtrCat_',num2str(ii-1)]);%#ok
            pirelab.getConcatenateComp(pathNet,pathPtr(ii,:),pathPtrCat(ii),'Multidimensional array',2);

            pathPtrCat_reg(ii)=pathNet.addSignal(ptrVecType,['pathPtrCat_reg_',num2str(ii-1)]);%#ok
            pirelab.getUnitDelayComp(pathNet,pathPtrCat(ii),pathPtrCat_reg(ii));
        end

        if dupLim~=2^nextpow2(dupLim)
            ptrPadConst=pathNet.addSignal(ptrVecType,'ptrPadConst');
            ptrPadConst.SimulinkRate=dataRate;
            pirelab.getConstComp(pathNet,ptrPadConst,0);

            for ii=dupLim+1:2^nextpow2(dupLim)
                pathPtrCat_reg(ii)=pathNet.addSignal(ptrVecType,['pathPtrDoutCat_reg_',num2str(ii-1)]);
                pirelab.getWireComp(pathNet,ptrPadConst,pathPtrCat_reg(ii));
            end
        end

        virtPtrRdAddr_reg=pathNet.addSignal(ptrAddrVecType,'virtPtrRdAddr_reg');
        pirelab.getUnitDelayComp(pathNet,virtPtrRdAddr,virtPtrRdAddr_reg);

        ptrDout=pathNet.addSignal(ptrVecType,'ptrDout');
        pirelab.getMultiPortSwitchComp(pathNet,[virtPtrRdAddr_reg,pathPtrCat_reg],ptrDout,2);
    end


    nextPathPtrAddr=pathNet.addSignal(KVecType,'nextVirtPtrAddr');
    pathPtr=pathNet.addSignal(pathVecType,'pathPtr');
    pirelab.getBitSliceComp(pathNet,ptrDout,nextPathPtrAddr,ptrType.WordLength-1,pathType.WordLength);
    pirelab.getBitSliceComp(pathNet,ptrDout,pathPtr,pathType.WordLength-1,0);

    pathPtrReached=pathNet.addSignal(ptrBoolVecType,'pathPtrReached');
    pirelab.getRelOpComp(pathNet,[nextPathPtrAddr,pathRdAddr_reg],pathPtrReached,'==');

    notPastPtrsEnd=pathNet.addSignal(ptrBoolVecType,'notPastPtrsEnd');

    incPathPtrRdAddr=pathNet.addSignal(ptrBoolVecType,'incPathPtrRdAddr');
    pirelab.getLogicComp(pathNet,[pathPtrReached,rdPath_reg,notPastPtrsEnd],incPathPtrRdAddr,'and');

    if listLength==2
        incPathPtrRdAddrDemux=incPathPtrRdAddr;
    else
        incPathPtrRdAddrDemux=pirelab.demuxSignal(pathNet,incPathPtrRdAddr);
    end

    for ii=1:numPtrs
        prevCnt(ii)=pathNet.addSignal(ptrAddrType,'prevCnt');%#ok
        curCnt(ii)=pathNet.addSignal(ptrAddrType,'curCnt');%#ok
        newCnt(ii)=pathNet.addSignal(ptrAddrType,'newCnt');%#ok
        pirelab.getMultiPortSwitchComp(pathNet,[incPathPtrRdAddrDemux(ii),prevCnt(ii),newCnt(ii)],curCnt(ii),1);

        pirelab.getUnitDelayResettableComp(pathNet,curCnt(ii),prevCnt(ii),rstRdCnt,'reg',0,'',true,'',-1,true);
        pirelab.getIncrementSI(pathNet,prevCnt(ii),newCnt(ii));
    end

    if listLength==2
        pirelab.getWireComp(pathNet,curCnt,virtPtrRdAddr);
    else
        pirelab.getConcatenateComp(pathNet,curCnt,virtPtrRdAddr,'Multidimensional array',2);
    end

    pastPtrsEnd=pathNet.addSignal(ptrBoolVecType,'pastPtrsEnd');
    pirelab.getRelOpComp(pathNet,[nextPtrWrAddr,virtPtrRdAddr],pastPtrsEnd,'==');

    pastPtrsEnd_reg=pathNet.addSignal(ptrBoolVecType,'pastPtrsEnd_reg');
    pirelab.getUnitDelayComp(pathNet,pastPtrsEnd,pastPtrsEnd_reg);

    pirelab.getLogicComp(pathNet,pastPtrsEnd_reg,notPastPtrsEnd,'not');

    if listLength==2


        padPastPtrsEnd=pathNet.addSignal(boolVecType,'padPastPtrsEnd');
        pirelab.getConcatenateComp(pathNet,[pastPtrsEnd_reg,pastPtrsEnd_reg],padPastPtrsEnd,'Multidimensional array',2);

        padPathPtr=pathNet.addSignal(contPathsType,'padPathPtr');
        pirelab.getConcatenateComp(pathNet,[pathPtr,pathPtr],padPathPtr,'Multidimensional array',2);
    else

        padPastPtrsEnd=pastPtrsEnd_reg;
        padPathPtr=pathPtr;
    end

    pathConsts=pathNet.addSignal(contPathsType,'pathConsts');
    pathConsts.SimulinkRate=dataRate;
    pirelab.getConstComp(pathNet,pathConsts,0:listLength-1);

    physAddr=pathNet.addSignal(contPathsType,'physAddr');
    pirelab.getMultiPortSwitchComp(pathNet,[padPastPtrsEnd,padPathPtr,pathConsts],physAddr,2);

    physAddr_reg=pathNet.addSignal(contPathsType,'physAddr_reg');
    pirelab.getUnitDelayComp(pathNet,physAddr,physAddr_reg);















    physAddrDecat=pirelab.demuxSignal(pathNet,physAddr_reg);

    for ii=1:listLength
        reconPaths(ii)=pathNet.addSignal(decType,['reconPaths_',num2str(ii-1)]);%#ok
        pirelab.getMultiPortSwitchComp(pathNet,[physAddrDecat(ii),hardDecsDecat_reg],reconPaths(ii),1);
    end

    pirelab.getConcatenateComp(pathNet,reconPaths,canPaths,'Multidimensional array',2);

    maxDupsReached=pathNet.addSignal(ptrBoolVecType,'maxDupsReached');
    pirelab.getCompareToValueComp(pathNet,nextPtrWrAddr,maxDupsReached,'<',dupLim-1);

    if listLength==2
        pirelab.getWireComp(pathNet,maxDupsReached,copyEn);
    else
        pirelab.getBitwiseOpComp(pathNet,maxDupsReached,copyEn,'AND');
    end
end

