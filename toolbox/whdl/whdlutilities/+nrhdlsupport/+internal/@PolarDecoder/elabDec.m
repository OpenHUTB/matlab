function decNet=elabDec(this,topNet,blockInfo,dataRate)
    listLength=blockInfo.listLength;
    boolType=pir_boolean_t();
    boolVecType=pirelab.createPirArrayType(boolType,[1,listLength]);
    boolPruneType=pirelab.createPirArrayType(boolType,[1,listLength/2]);
    intLlrType=blockInfo.intLlrType;
    intLlrAbsType=pir_ufixpt_t(intLlrType.Wordlength,intLlrType.Fraction);
    intLlrDecType=pirelab.createPirArrayType(intLlrAbsType,[1,listLength]);
    pathType=blockInfo.pathType;
    pathVecType=pirelab.createPirArrayType(pathType,[1,listLength]);
    pathPruneType=pirelab.createPirArrayType(pathType,[1,listLength/2]);
    decType=blockInfo.decType;
    decVecType=pirelab.createPirArrayType(decType,[1,listLength]);
    decOptsType=pirelab.createPirArrayType(decType,[1,2*listLength]);
    metricType=blockInfo.metricType;
    metricVecType=pirelab.createPirArrayType(metricType,[1,listLength]);
    metricOptsType=pirelab.createPirArrayType(metricType,[1,2*listLength]);
    metricPruneType=pirelab.createPirArrayType(metricType,[1,listLength/2]);


    inportNames={'llrLeaf','activePathCnt','F','makeDec','copyEn','rstMetrics'};
    inTypes=[intLlrType,pathType,boolType,boolType,boolType,boolType];
    indataRates=dataRate*ones(1,length(inportNames));

    outportNames={'hardDecs','pathWrEn','contPaths','pathOrder','actvPathCntOut'};
    outTypes=[decVecType,boolType,pathVecType,pathVecType,pathType];

    decNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','Decision',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );

    llrLeaf=decNet.PirInputSignals(1);
    actvPathCntIn=decNet.PirInputSignals(2);
    F=decNet.PirInputSignals(3);
    makeDec=decNet.PirInputSignals(4);
    copyEn=decNet.PirInputSignals(5);
    rstMetrics=decNet.PirInputSignals(6);

    hardDecs=decNet.PirOutputSignals(1);
    pathWrEn=decNet.PirOutputSignals(2);
    contPaths=decNet.PirOutputSignals(3);
    pathOrder=decNet.PirOutputSignals(4);
    actvPathCntOut=decNet.PirOutputSignals(5);

    llrLeaf_reg=decNet.addSignal(intLlrType,'llrLeaf_reg');
    pathCnt_reg=decNet.addSignal(pathType,'pathCnt_reg');
    F_reg=decNet.addSignal(boolType,'F_reg');
    copyEn_reg=decNet.addSignal(boolType,'copyEn_reg');

    pirelab.getUnitDelayComp(decNet,llrLeaf,llrLeaf_reg);
    pirelab.getUnitDelayComp(decNet,actvPathCntIn,pathCnt_reg);
    pirelab.getUnitDelayComp(decNet,F,F_reg);
    pirelab.getUnitDelayComp(decNet,copyEn,copyEn_reg);

    metrics=decNet.addSignal(metricVecType,'metrics');


    wrInfo=decNet.addSignal(boolType,'wrInfo');
    pirelab.getLogicComp(decNet,[makeDec,F_reg],wrInfo,'and');

    dupPaths=decNet.addSignal(boolType,'dupPaths');

    oneActvPath=decNet.addSignal(boolType,'oneActvPath');
    pirelab.getCompareToValueComp(decNet,pathCnt_reg,oneActvPath,'<',1);

    if listLength==2
        pirelab.getWireComp(decNet,oneActvPath,dupPaths);
    else





        canDup=decNet.addSignal(boolType,'canDup');
        pirelab.getCompareToValueComp(decNet,pathCnt_reg,canDup,'<',listLength-1);


        metricsDecat=pirelab.demuxSignal(decNet,metrics);
        metricsNonZero=decNet.addSignal(boolType,'metricsNonZero');
        pirelab.getCompareToValueComp(decNet,metricsDecat(1),metricsNonZero,'~=',0);

        dupBeyond2=decNet.addSignal(boolType,'dupBeyond2');
        pirelab.getLogicComp(decNet,[canDup,metricsNonZero],dupBeyond2,'and');

        pirelab.getLogicComp(decNet,[oneActvPath,dupBeyond2],dupPaths,'or');
    end

    dupEn=decNet.addSignal(boolType,'dup');
    pirelab.getLogicComp(decNet,[wrInfo,dupPaths],dupEn,'and');


    doubleActvPathCnt=decNet.addSignal(pathType,'doubleActvPathCnt');
    pirelab.getGainComp(decNet,pathCnt_reg,doubleActvPathCnt,fi(2,0,2,0));

    nextActvPathCnt=decNet.addSignal(pathType,'nextActvPathCnt');
    pirelab.getIncrementRWV(decNet,doubleActvPathCnt,nextActvPathCnt);


    newActvPathCnt=decNet.addSignal(pathType,'newActvPathCnt');
    pirelab.getMultiPortSwitchComp(decNet,[dupEn,pathCnt_reg,nextActvPathCnt],newActvPathCnt,1);


    dec=decNet.addSignal(decType,'dec');
    pirelab.getCompareToValueComp(decNet,llrLeaf_reg,dec,'<',0);

    decs=decNet.addSignal(decVecType,'decs');
    pirelab.getTapDelayComp(decNet,dec,decs,listLength-1,'tapdelay',0,false,true);


    llrAb=decNet.addSignal(intLlrAbsType,'llrAb');
    pirelab.getAbsComp(decNet,llrLeaf_reg,llrAb);

    llrAbs=decNet.addSignal(intLlrDecType,'llrAbs');
    pirelab.getTapDelayComp(decNet,llrAb,llrAbs,listLength-1,'tapdelay',0,false,true);


    newMetrics=decNet.addSignal(metricVecType,'newMetrics');
    pirelab.getAddComp(decNet,[llrAbs,metrics],newMetrics,'Floor','Saturate');


    contPathType=pir_ufixpt_t(pathType.WordLength+1,0);
    contPathVecType=pirelab.createPirArrayType(contPathType,[1,listLength]);

    contPathsInt=decNet.addSignal(contPathVecType,'contPathsInt');
    newActvPathCnt_dBal=decNet.addSignal(pathType,'newActvPathCnt_dBal');

    if listLength==2

        newMetricsFlip=decNet.addSignal(metricVecType,'newMetricsFlip');
        pirelab.getSelectorComp(decNet,newMetrics,newMetricsFlip,'one-based',...
        {'Index vector (dialog)','Index vector (dialog)'},...
        {1,2:-1:1},...
        {'Inherit from "Index"','Inherit from "Index"'},'2');

        newPathLT=decNet.addSignal(boolVecType,'newPathLT');
        pirelab.getRelOpComp(decNet,[newMetricsFlip,metrics],newPathLT,'<');


        replPath=decNet.addSignal(boolVecType,'replPath');
        pirelab.getLogicComp(decNet,[copyEn_reg,newPathLT],replPath,'and');

        oldPathsIdx=decNet.addSignal(contPathVecType,'oldPathsIdx');
        oldPathsIdx.SimulinkRate=dataRate;
        newPathsIdx=decNet.addSignal(contPathVecType,'newPathsIdx');
        newPathsIdx.SimulinkRate=dataRate;
        pirelab.getConstComp(decNet,oldPathsIdx,[0,1]);
        pirelab.getConstComp(decNet,newPathsIdx,[3,2]);

        metricContPaths=decNet.addSignal(contPathVecType,'metricContPaths');
        pirelab.getMultiPortSwitchComp(decNet,[replPath,oldPathsIdx,newPathsIdx],metricContPaths,2);

        dupContPaths=decNet.addSignal(contPathVecType,'dupContPaths');
        dupContPaths.SimulinkRate=dataRate;
        pirelab.getConstComp(decNet,dupContPaths,[0,2]);



        pirelab.getWireComp(decNet,newActvPathCnt,newActvPathCnt_dBal);

        pirelab.getMultiPortSwitchComp(decNet,[dupEn,metricContPaths,dupContPaths],contPathsInt,1);
    else

        unsortedMetrics=decNet.addSignal(metricVecType,'unsortedMetrics');
        pirelab.getMultiPortSwitchComp(decNet,[makeDec,metrics,newMetrics],unsortedMetrics,1);

        sortedMetrics=decNet.addSignal(metricVecType,'sortedMetrics');
        sortedIndices=decNet.addSignal(pathVecType,'sortedIndices');

        sortNet=this.elabOptSorter(decNet,blockInfo,dataRate);

        inports=unsortedMetrics;
        outports=[sortedMetrics,sortedIndices];

        pirelab.instantiateNetwork(decNet,sortNet,inports,outports,'sortNet_inst');


        sorterDelay=sum(blockInfo.sorterPipes);




        topUpdatedMetrics=decNet.addSignal(metricPruneType,'topUpdatedMetrics');
        pirelab.getSelectorComp(decNet,sortedMetrics,topUpdatedMetrics,'one-based',...
        {'Index vector (dialog)','Index vector (dialog)'},...
        {1,listLength/2:-1:1},...
        {'Inherit from "Index"','Inherit from "Index"'},'2');

        topUpdatedIndices=decNet.addSignal(pathPruneType,'topUpdatedMetrics');
        pirelab.getSelectorComp(decNet,sortedIndices,topUpdatedIndices,'one-based',...
        {'Index vector (dialog)','Index vector (dialog)'},...
        {1,1:listLength/2},...
        {'Inherit from "Index"','Inherit from "Index"'},'2');




        sortedMetrics_reg=decNet.addSignal(metricVecType,'sortedMetrics_reg');
        sortedIndices_reg=decNet.addSignal(pathVecType,'sortedIndices_reg');
        pirelab.getUnitDelayComp(decNet,sortedMetrics,sortedMetrics_reg);
        pirelab.getUnitDelayComp(decNet,sortedIndices,sortedIndices_reg);










        botCurMetrics4Actv=decNet.addSignal(metricPruneType,'botCurMetrics4Actv');
        pirelab.getSelectorComp(decNet,sortedMetrics_reg,botCurMetrics4Actv,'one-based',...
        {'Index vector (dialog)','Index vector (dialog)'},...
        {1,listLength/2+1:listLength},...
        {'Inherit from "Index"','Inherit from "Index"'},'2');

        botCurIndices4Actv=decNet.addSignal(pathPruneType,'botCurMetrics4Actv');
        pirelab.getSelectorComp(decNet,sortedIndices_reg,botCurIndices4Actv,'one-based',...
        {'Index vector (dialog)','Index vector (dialog)'},...
        {1,listLength/2+1:listLength},...
        {'Inherit from "Index"','Inherit from "Index"'},'2');


        if listLength==4
            bot2Indices=1:listLength/2;
        else
            bot2Indices=[3,4,1,2];
        end

        botCurMetrics2Actv=decNet.addSignal(metricPruneType,'botCurMetrics2Actv');
        pirelab.getSelectorComp(decNet,sortedMetrics_reg,botCurMetrics2Actv,'one-based',...
        {'Index vector (dialog)','Index vector (dialog)'},...
        {1,bot2Indices},...
        {'Inherit from "Index"','Inherit from "Index"'},'2');

        botCurIndices2Actv=decNet.addSignal(pathPruneType,'botCurMetrics2Actv');
        pirelab.getSelectorComp(decNet,sortedIndices_reg,botCurIndices2Actv,'one-based',...
        {'Index vector (dialog)','Index vector (dialog)'},...
        {1,bot2Indices},...
        {'Inherit from "Index"','Inherit from "Index"'},'2');


        newActvPathCnt_reg=decNet.addSignal(pathType,'newActvPathCnt_reg');
        pirelab.getIntDelayComp(decNet,newActvPathCnt,newActvPathCnt_reg,sorterDelay);

        for ii=1:log2(listLength)-1
            isCurActvPathCnt(ii)=decNet.addSignal(boolType,['isCurActvPathCnt_',num2str(ii-1)]);%#ok
            pirelab.getCompareToValueComp(decNet,newActvPathCnt_reg,isCurActvPathCnt(ii),'==',2^ii-1);

            isCurActvPathCnt_reg(ii)=decNet.addSignal(boolType,['isCurActvPathCnt_reg_',num2str(ii-1)]);%#ok
            pirelab.getUnitDelayComp(decNet,isCurActvPathCnt(ii),isCurActvPathCnt_reg(ii));
        end

        botCurMetrics=decNet.addSignal(metricPruneType,'botCurMetrics');
        pirelab.getMultiPortSwitchComp(decNet,[isCurActvPathCnt(1),botCurMetrics4Actv,botCurMetrics2Actv],botCurMetrics,1);

        botCurIndices=decNet.addSignal(pathPruneType,'botCurIndices');
        pirelab.getMultiPortSwitchComp(decNet,[isCurActvPathCnt(1),botCurIndices4Actv,botCurIndices2Actv],botCurIndices,1);

        dupEn_reg=decNet.addSignal(boolType,'dupEn_reg');
        pirelab.getIntDelayComp(decNet,dupEn,dupEn_reg,1+sorterDelay);



        if listLength==4
            topUpdatedMetrics_pipe=decNet.addSignal(metricPruneType,'topUpdatedMetrics_reg');
            topUpdatedIndices_pipe=decNet.addSignal(pathPruneType,'topUpdatedIndices_reg');
            botCurMetrics_pipe=decNet.addSignal(metricPruneType,'botCurMetrics_reg');
            botCurIndices_pipe=decNet.addSignal(pathPruneType,'botCurIndices_reg');

            pirelab.getUnitDelayComp(decNet,topUpdatedMetrics,topUpdatedMetrics_pipe);
            pirelab.getUnitDelayComp(decNet,topUpdatedIndices,topUpdatedIndices_pipe);
            pirelab.getUnitDelayComp(decNet,botCurMetrics,botCurMetrics_pipe);
            pirelab.getUnitDelayComp(decNet,botCurIndices,botCurIndices_pipe);
        else
            topUpdatedMetrics_pipe=topUpdatedMetrics;
            topUpdatedIndices_pipe=topUpdatedIndices;
            botCurMetrics_pipe=botCurMetrics;
            botCurIndices_pipe=botCurIndices;
        end

        overwritePath=decNet.addSignal(boolPruneType,'overwritePath');
        pirelab.getRelOpComp(decNet,[botCurMetrics_pipe,topUpdatedMetrics_pipe],overwritePath,'>');

        botCurIndicesDecat=pirelab.demuxSignal(decNet,botCurIndices_pipe);
        overwritePathDecat=pirelab.demuxSignal(decNet,overwritePath);

        oldPathsIdx=decNet.addSignal(contPathVecType,'oldPathsIdx');
        oldPathsIdx.SimulinkRate=dataRate;
        pirelab.getConstComp(decNet,oldPathsIdx,0:listLength-1);


        topUpdatedIndicesDecat=pirelab.demuxSignal(decNet,topUpdatedIndices_pipe);

        listLengthConst=decNet.addSignal(contPathType,'listLengthConst');
        listLengthConst.SimulinkRate=dataRate;
        pirelab.getConstComp(decNet,listLengthConst,listLength);

        for ii=1:listLength/2



            botCurIdxPos(ii)=decNet.addSignal(boolVecType,'botCurIdxPos');%#ok
            pirelab.getCompareToValueComp(decNet,botCurIndicesDecat(ii),botCurIdxPos(ii),'==',0:listLength-1);

            overwritePathAtPos(ii)=decNet.addSignal(boolVecType,['overwritePathAtPos_',num2str(ii-1)]);%#ok
            pirelab.getLogicComp(decNet,[overwritePathDecat(ii),botCurIdxPos(ii)],overwritePathAtPos(ii),'and');

            newPathsIdx(ii)=decNet.addSignal(contPathType,['newPathsIdx_',num2str(ii-1)]);%#ok
            pirelab.getAddComp(decNet,[topUpdatedIndicesDecat(ii),listLengthConst],newPathsIdx(ii));

            if listLength==4
                newPathsIdx_pipe(ii)=newPathsIdx(ii);%#ok
                overwritePathAtPos_pipe(ii)=overwritePathAtPos(ii);%#ok
            else
                newPathsIdx_pipe(ii)=decNet.addSignal(contPathType,['newPathsIdx_reg_',num2str(ii-1)]);%#ok
                overwritePathAtPos_pipe(ii)=decNet.addSignal(boolVecType,['overwritePathAtPos_reg_',num2str(ii-1)]);%#ok
                pirelab.getUnitDelayComp(decNet,newPathsIdx(ii),newPathsIdx_pipe(ii));
                pirelab.getUnitDelayComp(decNet,overwritePathAtPos(ii),overwritePathAtPos_pipe(ii));
            end


            newPathsIdxPad(ii)=decNet.addSignal(contPathVecType,['newPathsIdxPad_',num2str(ii-1)]);%#ok
            pirelab.getConcatenateComp(decNet,repmat(newPathsIdx_pipe(ii),1,listLength),newPathsIdxPad(ii),'Multidimensional array',2);
        end

        for ii=1:listLength/2
            if ii==1
                prevMetricSel=oldPathsIdx;
            else
                prevMetricSel=metricContPathsSel(ii-1);
            end

            metricContPathsSel(ii)=decNet.addSignal(contPathVecType,['contPathsSel_',num2str(ii-1)]);%#ok
            pirelab.getMultiPortSwitchComp(decNet,[overwritePathAtPos_pipe(ii),prevMetricSel,newPathsIdxPad(listLength/2-ii+1)],metricContPathsSel(ii),2);
        end

        metricContPaths=decNet.addSignal(contPathVecType,'metricContPaths');
        pirelab.getWireComp(decNet,metricContPathsSel(listLength/2),metricContPaths);

        for ii=1:log2(listLength)
            dupIdxConsts(ii)=decNet.addSignal(contPathVecType,['dupIdxConsts_',num2str(ii-1)]);%#ok
            dupIdxConsts(ii).SimulinkRate=dataRate;%#ok
            pirelab.getConstComp(decNet,dupIdxConsts(ii),[0:2^(ii-1)-1,listLength:listLength+2^(ii-1)-1,2^(ii):listLength-1]);
        end

        for ii=1:log2(listLength)-1
            if ii==1
                prevDupSel=dupIdxConsts(log2(listLength));
            else
                prevDupSel=dupContPathsSel(ii-1);
            end
            dupContPathsSel(ii)=decNet.addSignal(contPathVecType,'dupContPathsSel');%#ok
            pirelab.getMultiPortSwitchComp(decNet,[isCurActvPathCnt_reg(log2(listLength)-ii),prevDupSel,dupIdxConsts(log2(listLength)-ii)],dupContPathsSel(ii),1);
        end
        dupContPaths=decNet.addSignal(contPathVecType,'dupContPaths');
        pirelab.getWireComp(decNet,dupContPathsSel(log2(listLength)-1),dupContPaths);



        pruneContPaths=decNet.addSignal(contPathVecType,'pruneContPaths');
        pirelab.getMultiPortSwitchComp(decNet,[dupEn_reg,metricContPaths,dupContPaths],pruneContPaths,1);


        copyEn_dBal=decNet.addSignal(boolType,'copyEn_dBal');
        pirelab.getIntDelayComp(decNet,copyEn_reg,copyEn_dBal,1+sorterDelay);
        pirelab.getIntDelayComp(decNet,newActvPathCnt,newActvPathCnt_dBal,1+sorterDelay);

        pathsActv(1)=decNet.addSignal(boolType,'pathsActv_0');
        pathsActv(1).SimulinkRate=dataRate;
        pirelab.getConstComp(decNet,pathsActv(1),1);

        for ii=1:listLength-1
            pathsActv(ii+1)=decNet.addSignal(boolType,['pathsActv_',num2str(ii)]);%#ok
            compVal=2^(floor(log2(ii))+1)-1;
            pirelab.getCompareToValueComp(decNet,newActvPathCnt_dBal,pathsActv(ii+1),'>=',compVal);
        end


        pathsActvCat=decNet.addSignal(boolVecType,'pathsActv');
        pirelab.getConcatenateComp(decNet,pathsActv,pathsActvCat,'Multidimensional array',2);


        pathOverwriteEn=decNet.addSignal(boolVecType,'pathOverwriteEn');
        pirelab.getLogicComp(decNet,[copyEn_dBal,pathsActvCat],pathOverwriteEn,'and');

        pirelab.getMultiPortSwitchComp(decNet,[pathOverwriteEn,oldPathsIdx,pruneContPaths],contPathsInt,2);
    end


    contPaths_reg=decNet.addSignal(contPathVecType,'contPathsInt_reg');
    newMetrics_reg=decNet.addSignal(metricVecType,'newMetrics_reg');
    decs_reg=decNet.addSignal(decVecType,'decs_reg');
    makeDec_reg=decNet.addSignal(boolType,'makeDec_reg');
    rstMetrics_reg=decNet.addSignal(boolType,'rstMetrics_reg');
    pirelab.getUnitDelayComp(decNet,contPathsInt,contPaths_reg);
    pirelab.getUnitDelayComp(decNet,newMetrics,newMetrics_reg);
    pirelab.getUnitDelayComp(decNet,decs,decs_reg);
    pirelab.getUnitDelayComp(decNet,makeDec,makeDec_reg);
    pirelab.getUnitDelayComp(decNet,rstMetrics,rstMetrics_reg);

    wrInfo_dBal=decNet.addSignal(boolType,'wrInfo_dBal');
    newInfoMetrics=decNet.addSignal(metricVecType,'newInfoMetrics');
    metricWrEn=decNet.addSignal(boolType,'metricWrEn');
    decs_dBal=decNet.addSignal(decVecType,'decs_dBal');
    rstMetrics_dBal=decNet.addSignal(boolType,'rstMetrics_dBal');

    if listLength==2

        pirelab.getWireComp(decNet,wrInfo,wrInfo_dBal);
        pirelab.getWireComp(decNet,newMetrics_reg,newInfoMetrics);
        pirelab.getWireComp(decNet,makeDec_reg,metricWrEn);
        pirelab.getWireComp(decNet,decs_reg,decs_dBal);
        pirelab.getWireComp(decNet,rstMetrics_reg,rstMetrics_dBal);
    else

        pirelab.getIntDelayComp(decNet,wrInfo,wrInfo_dBal,1+sorterDelay);
        pirelab.getIntDelayComp(decNet,newMetrics_reg,newInfoMetrics,1+sorterDelay);
        pirelab.getIntDelayComp(decNet,decs_reg,decs_dBal,1+sorterDelay);
        pirelab.getIntDelayComp(decNet,rstMetrics_reg,rstMetrics_dBal,1+sorterDelay);



        notF=decNet.addSignal(boolType,'notF');
        pirelab.getLogicComp(decNet,F_reg,notF,'not');

        wrFrozen=decNet.addSignal(boolType,'wrInfo');
        pirelab.getLogicComp(decNet,[makeDec,notF],wrFrozen,'and');

        wrInfoOrFrozen=decNet.addSignal(boolType,'wrInfoOrFrozen');
        pirelab.getLogicComp(decNet,[wrFrozen,wrInfo_dBal],wrInfoOrFrozen,'or');

        pirelab.getUnitDelayComp(decNet,wrInfoOrFrozen,metricWrEn);

        pathsActvCat_reg=decNet.addSignal(boolVecType,'pathsActvCat_reg');
        pirelab.getUnitDelayComp(decNet,pathsActvCat,pathsActvCat_reg);
    end

    notDecs=decNet.addSignal(decVecType,'notDecs');
    pirelab.getLogicComp(decNet,decs_dBal,notDecs,'not');

    decOptions=decNet.addSignal(decOptsType,'decOptions');
    pirelab.getConcatenateComp(decNet,[decs_dBal,notDecs],decOptions,'Multidimensional array',2);

    metricOptions=decNet.addSignal(metricOptsType,'metricOptions');
    pirelab.getConcatenateComp(decNet,[metrics,newInfoMetrics],metricOptions,'Multidimensional array',2);

    contPathsDemux=pirelab.demuxSignal(decNet,contPaths_reg);
    for ii=1:listLength
        contDecs(ii)=decNet.addSignal(decType,['contDecs_',num2str(ii-1)]);%#ok
        pirelab.getMultiPortSwitchComp(decNet,[contPathsDemux(ii),decOptions],contDecs(ii),0);

        infoMetrics(ii)=decNet.addSignal(metricType,['infoMetrics_',num2str(ii-1)]);%#ok
        pirelab.getMultiPortSwitchComp(decNet,[contPathsDemux(ii),metricOptions],infoMetrics(ii),0);
    end

    contDecsCat=decNet.addSignal(decVecType,['contDecsCat_',num2str(ii-1)]);
    pirelab.getConcatenateComp(decNet,contDecs,contDecsCat,'Multidimensional array',2);

    infoMetricsCat=decNet.addSignal(metricVecType,['infoMetricsCat',num2str(ii-1)]);
    pirelab.getConcatenateComp(decNet,infoMetrics,infoMetricsCat,'Multidimensional array',2);

    frozMetrics=decNet.addSignal(metricVecType,'frozMetrics');
    pirelab.getMultiPortSwitchComp(decNet,[decs_reg,metrics,newMetrics_reg],frozMetrics,2);





    actvMetricWrEn=decNet.addSignal(boolVecType,'actvMetricWrEn');
    if listLength==2
        pirelab.getConcatenateComp(decNet,repmat(metricWrEn,listLength,1),actvMetricWrEn,'Multidimensional array',2);
    else
        pirelab.getLogicComp(decNet,[pathsActvCat_reg,metricWrEn],actvMetricWrEn,'and');
    end



    updateMetrics=decNet.addSignal(metricVecType,'updateMetrics');
    pirelab.getMultiPortSwitchComp(decNet,[F_reg,frozMetrics,infoMetricsCat],updateMetrics,1);

    updateMetricsDemux=pirelab.demuxSignal(decNet,updateMetrics);
    metricWrEnDemux=pirelab.demuxSignal(decNet,actvMetricWrEn);

    for ii=1:listLength
        if ii>2
            ic=fi(realmax,numerictype(0,metricType.WordLength,-metricType.FractionLength));
        else
            ic=0;
        end

        metricsDemux(ii)=decNet.addSignal(metricType,['metricsDemux_',ii-1]);%#ok
        pirelab.getUnitDelayEnabledResettableComp(decNet,updateMetricsDemux(ii),metricsDemux(ii),metricWrEnDemux(ii),rstMetrics_dBal,...
        'metricReg',ic,'',true,'',-1,true);
    end

    pirelab.getConcatenateComp(decNet,metricsDemux,metrics,'Multidimensional array',2);

    if listLength==2
        metricsFlip=decNet.addSignal(metricVecType,'metricsFlip');
        pirelab.getSelectorComp(decNet,metrics,metricsFlip,'one-based',...
        {'Index vector (dialog)','Index vector (dialog)'},...
        {1,listLength:-1:1},...
        {'Inherit from "Index"','Inherit from "Index"'},'2');

        pirelab.getRelOpComp(decNet,[metricsFlip,metrics],pathOrder,'<');
    else
        pirelab.getWireComp(decNet,sortedIndices_reg,pathOrder);
    end

    pirelab.getWireComp(decNet,contDecsCat,hardDecs);
    pirelab.getUnitDelayComp(decNet,wrInfo_dBal,pathWrEn);
    pirelab.getBitSliceComp(decNet,contPathsInt,contPaths,pathType.WordLength-1,0);
    pirelab.getWireComp(decNet,newActvPathCnt_dBal,actvPathCntOut);
end
