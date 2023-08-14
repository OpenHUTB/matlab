function ptrMemNet=elabPtrMem(this,topNet,blockInfo,dataRate)
    listLength=blockInfo.listLength;
    nMax=blockInfo.nMax;
    boolType=pir_boolean_t();
    stageType=blockInfo.stageType;
    pathType=blockInfo.pathType;
    pathVecType=pirelab.createPirArrayType(pathType,[1,listLength]);
    betaPathType=pirelab.createPirArrayType(pathType,[1,nMax]);


    inportNames={'contPaths','dupPtrWrEn','wrStage','rdStage','wrPath','alphaUpdateWrEn','betaUpdateWrEn'};
    inTypes=[pathVecType,boolType,stageType,stageType,pathType,boolType,boolType];
    indataRates=dataRate*ones(1,length(inportNames));

    outportNames={'alphaRdPath','betaRdPaths'};
    outTypes=[pathType,betaPathType];

    ptrMemNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','ptrMem',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );

    contPaths=ptrMemNet.PirInputSignals(1);
    dupPtrWrEn=ptrMemNet.PirInputSignals(2);
    wrStage=ptrMemNet.PirInputSignals(3);
    rdStage=ptrMemNet.PirInputSignals(4);
    wrPath=ptrMemNet.PirInputSignals(5);
    alphaUpdateWrEn=ptrMemNet.PirInputSignals(6);
    betaUpdateWrEn=ptrMemNet.PirInputSignals(7);

    alphaRdPath=ptrMemNet.PirOutputSignals(1);
    betaRdPaths=ptrMemNet.PirOutputSignals(2);

    contPathsDemux=pirelab.demuxSignal(ptrMemNet,contPaths);

    stageConst=ptrMemNet.addSignal(pathVecType,'stageConst');
    stageConst.SimulinkRate=dataRate;
    pirelab.getConstComp(ptrMemNet,stageConst,0:listLength-1);

    stageConstDemux=pirelab.demuxSignal(ptrMemNet,stageConst);

    for ii=1:nMax-1
        alphaStageComp(ii)=ptrMemNet.addSignal(boolType,['alphaStageComp_',num2str(ii-1)]);%#ok
        pirelab.getCompareToValueComp(ptrMemNet,wrStage,alphaStageComp(ii),'==',ii-1);

        alphaStageWrEn(ii)=ptrMemNet.addSignal(boolType,['alphaStageWrEn',num2str(ii-1)]);%#ok
        pirelab.getLogicComp(ptrMemNet,[alphaUpdateWrEn,alphaStageComp(ii)],alphaStageWrEn(ii),'and');

        alphaPtrWrEn(ii)=ptrMemNet.addSignal(boolType,['alphaPtrWrEn_',num2str(ii-1)]);%#ok
        pirelab.getLogicComp(ptrMemNet,[alphaStageWrEn(ii),dupPtrWrEn],alphaPtrWrEn(ii),'or');

        betaStageComp(ii)=ptrMemNet.addSignal(boolType,['betaStageComp_',num2str(ii-1)]);%#ok
        pirelab.getCompareToValueComp(ptrMemNet,rdStage,betaStageComp(ii),'==',ii-1);

        betaStageWrEn(ii)=ptrMemNet.addSignal(boolType,['betaStageWrEn_',num2str(ii-1)]);%#ok
        pirelab.getLogicComp(ptrMemNet,[betaUpdateWrEn,betaStageComp(ii)],betaStageWrEn(ii),'and');

        betaPtrWrEn(ii)=ptrMemNet.addSignal(boolType,['betaPtrWrEn_',num2str(ii-1)]);%#ok
        pirelab.getLogicComp(ptrMemNet,[betaStageWrEn(ii),dupPtrWrEn],betaPtrWrEn(ii),'or');

        for jj=1:listLength
            alphaPtr(ii,jj)=ptrMemNet.addSignal(pathType,['alphaPtr_',num2str(ii-1),'_',num2str(jj-1)]);%#ok
            betaPtr(ii,jj)=ptrMemNet.addSignal(pathType,['betaPtr_',num2str(ii-1),'_',num2str(jj-1)]);%#ok
        end
        for jj=1:listLength
            copiedAlphaPtr(ii,jj)=ptrMemNet.addSignal(pathType,['copiedAlphaPtr_',num2str(ii-1),'_',num2str(jj-1)]);%#ok
            pirelab.getMultiPortSwitchComp(ptrMemNet,[contPathsDemux(jj),alphaPtr(ii,:)],copiedAlphaPtr(ii,jj),1);

            newAlphaPtr(ii,jj)=ptrMemNet.addSignal(pathType,['newAlphaPtr_',num2str(ii-1),'_',num2str(jj-1)]);%#ok
            pirelab.getMultiPortSwitchComp(ptrMemNet,[alphaStageWrEn(ii),copiedAlphaPtr(ii,jj),stageConstDemux(jj)],newAlphaPtr(ii,jj),1);

            pirelab.getUnitDelayEnabledComp(ptrMemNet,newAlphaPtr(ii,jj),alphaPtr(ii,jj),alphaPtrWrEn(ii),['alphaPtrReg_',num2str(ii),'_',num2str(jj)],'','',false,'',-1,true);

            copiedBetaPtr(ii,jj)=ptrMemNet.addSignal(pathType,['copiedBetaPtr_',num2str(ii-1),'_',num2str(jj-1)]);%#ok
            pirelab.getMultiPortSwitchComp(ptrMemNet,[contPathsDemux(jj),betaPtr(ii,:)],copiedBetaPtr(ii,jj),1);

            newBetaPtr(ii,jj)=ptrMemNet.addSignal(pathType,['newBetaPtr_',num2str(ii-1),'_',num2str(jj-1)]);%#ok
            pirelab.getMultiPortSwitchComp(ptrMemNet,[betaStageWrEn(ii),copiedBetaPtr(ii,jj),stageConstDemux(jj)],newBetaPtr(ii,jj),1);

            pirelab.getUnitDelayEnabledComp(ptrMemNet,newBetaPtr(ii,jj),betaPtr(ii,jj),betaPtrWrEn(ii),['betaPtrReg_',num2str(ii),'_',num2str(jj)],'','',false,'',-1,true);
        end

        pathAlphaPtr(ii)=ptrMemNet.addSignal(pathType,['pathAlphaPtr_',num2str(ii-1)]);%#ok
        pirelab.getMultiPortSwitchComp(ptrMemNet,[wrPath,alphaPtr(ii,:)],pathAlphaPtr(ii),1);

        pathBetaPtr(ii)=ptrMemNet.addSignal(pathType,['pathBetaPtr_',num2str(ii-1)]);%#ok
        pirelab.getMultiPortSwitchComp(ptrMemNet,[wrPath,betaPtr(ii,:)],pathBetaPtr(ii),1);
    end

    zeroConst=ptrMemNet.addSignal(pathType,'zeroConst');
    zeroConst.SimulinkRate=dataRate;
    pirelab.getConstComp(ptrMemNet,zeroConst,0);

    pirelab.getMultiPortSwitchComp(ptrMemNet,[rdStage,pathAlphaPtr,repmat(zeroConst,1,16-nMax+1)],alphaRdPath,1);
    pirelab.getConcatenateComp(ptrMemNet,[pathBetaPtr,zeroConst],betaRdPaths,'Multidimensional array',2);
end