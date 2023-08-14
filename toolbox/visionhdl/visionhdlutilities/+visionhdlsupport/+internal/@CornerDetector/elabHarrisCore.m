function FASTCoreNet=elabHarrisCore(~,topNet,blockInfo,dataRate)






    ctrlType=pir_boolean_t();

    iports={'pixelInVec','ShiftEnb','hStartIn','hEndIn','vStartIn','vEndIn','validIn'};
    itypes=[blockInfo.pixelInVecDT,ctrlType,ctrlType,ctrlType,ctrlType,ctrlType,ctrlType];
    irates=[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate];
    if blockInfo.numInputPorts==3
        iports{end+1}='thresh';
        itypes(end+1)=blockInfo.outportCornerType;
        irates(end+1)=dataRate;
    end
    oports={'cornerOut','hStartOut','hEndOut','vStartOut','vEndOut','validOut'};
    otypes=[blockInfo.outportCornerType,ctrlType,ctrlType,ctrlType,ctrlType,ctrlType];

    FASTCoreNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','HarrisCore',...
    'InportNames',iports,...
    'InportTypes',itypes,...
    'InportRates',irates,...
    'OutportNames',oports,...
    'OutportTypes',otypes);



    pixelInVec=FASTCoreNet.PirInputSignals(1);
    tapValidIn=FASTCoreNet.PirInputSignals(2);
    hStartIn=FASTCoreNet.PirInputSignals(3);
    hEndIn=FASTCoreNet.PirInputSignals(4);
    vStartIn=FASTCoreNet.PirInputSignals(5);
    vEndIn=FASTCoreNet.PirInputSignals(6);
    validIn=FASTCoreNet.PirInputSignals(7);

    cornerOut=FASTCoreNet.PirOutputSignals(1);
    hStartOut=FASTCoreNet.PirOutputSignals(2);
    hEndOut=FASTCoreNet.PirOutputSignals(3);
    vStartOut=FASTCoreNet.PirOutputSignals(4);
    vEndOut=FASTCoreNet.PirOutputSignals(5);
    validOut=FASTCoreNet.PirOutputSignals(6);

    inputType=pixelInVec.Type;
    inWL=inputType.BaseType.WordLength;
    inFL=inputType.BaseType.FractionLength;

    cornerOutType=blockInfo.outportCornerType;

    threshType=cornerOutType;




    tapInData=pixelInVec(1).split;
    tapOutvType=pirelab.getPirVectorType(pixelInVec.Type.BaseType,blockInfo.KernelWidth);
    tapDelayOrder=true;
    includeCurrent=true;

    for ii=1:blockInfo.KernelHeight
        iiStr=num2str(ii);

        tapOutSigVec(ii)=FASTCoreNet.addSignal(tapOutvType,...
        ['tapOutData_',iiStr]);%#ok<AGROW>


        pirelab.getTapDelayEnabledComp(FASTCoreNet,...
        tapInData.PirOutputSignals(ii),tapOutSigVec(ii),tapValidIn,...
        blockInfo.KernelWidth-1,['tapDelay_',iiStr],0,tapDelayOrder,...
        includeCurrent);




        tapOutSigSplit=tapOutSigVec(ii).split;
        for jj=1:numel(tapOutSigSplit.PirOutputSignals)

            tapOutSig(ii,jj)=tapOutSigSplit.PirOutputSignals(jj);%#ok<AGROW>
        end
    end


    tapOutSigFlat=tapOutSig(:);

    if blockInfo.numInputPorts==3
        minContrastSig=FASTCoreNet.PirInputSignals(8);
    else
        minContrastSig=FASTCoreNet.addSignal(threshType,'thresholdValue');
        fiMinContrast=fi(blockInfo.Threshold,threshType.Signed,threshType.WordLength,-1*threshType.FractionLength);
        pirelab.getConstComp(FASTCoreNet,minContrastSig,fiMinContrast);
    end

    edgeType=FASTCoreNet.getType('FixedPoint','Signed',true,...
    'WordLength',inWL+2,...
    'FractionLength',inFL);

    hCastA=FASTCoreNet.addSignal(edgeType,'hCastA');
    hCastB=FASTCoreNet.addSignal(edgeType,'hCastB');
    vCastA=FASTCoreNet.addSignal(edgeType,'vCastA');
    vCastB=FASTCoreNet.addSignal(edgeType,'vCastB');

    horizSub=FASTCoreNet.addSignal(edgeType,'horizSub');
    vertSub=FASTCoreNet.addSignal(edgeType,'vertSub');

    horizReg=FASTCoreNet.addSignal(edgeType,'horizReg');
    vertReg=FASTCoreNet.addSignal(edgeType,'vertReg');
    hCastA.SimulinkRate=dataRate;
    hCastB.SimulinkRate=dataRate;
    vCastA.SimulinkRate=dataRate;
    vCastB.SimulinkRate=dataRate;
    horizSub.SimulinkRate=dataRate;
    vertSub.SimulinkRate=dataRate;
    horizReg.SimulinkRate=dataRate;
    vertReg.SimulinkRate=dataRate;




    hvZero=FASTCoreNet.addSignal(edgeType,'hvZero');
    hvZero.SimulinkRate=dataRate;
    pirelab.getConstComp(FASTCoreNet,hvZero,0);

    mulType=FASTCoreNet.getType('FixedPoint','Signed',true,...
    'WordLength',2*(inWL+2),...
    'FractionLength',2*inFL);

    xSquared=FASTCoreNet.addSignal(mulType,'xSquared');
    ySquared=FASTCoreNet.addSignal(mulType,'ySquared');
    xy=FASTCoreNet.addSignal(mulType,'xy');
    xSquared.SimulinkRate=dataRate;
    ySquared.SimulinkRate=dataRate;
    xy.SimulinkRate=dataRate;



    kernelDelay=1;

    hStartDly=FASTCoreNet.addSignal(ctrlType,'hStartDly');
    hEndDly=FASTCoreNet.addSignal(ctrlType,'hEndDly');
    vStartDly=FASTCoreNet.addSignal(ctrlType,'vStartDly');
    vEndDly=FASTCoreNet.addSignal(ctrlType,'vEndDly');
    validDly=FASTCoreNet.addSignal(ctrlType,'validDly');
    hStartDly.SimulinkRate=dataRate;
    hEndDly.SimulinkRate=dataRate;
    vStartDly.SimulinkRate=dataRate;
    vEndDly.SimulinkRate=dataRate;
    valid.Dly.SimulinkRate=dataRate;

    if strcmpi(blockInfo.PaddingMethod,'None')
        validREG=FASTCoreNet.addSignal(ctrlType,'validREG');
        validREG.SimulinkRate=dataRate;

        hsOKDelay=FASTCoreNet.addSignal(ctrlType,'hStartOutKernelDelay');
        hsOKDelay.SimulinkRate=dataRate;
        pirelab.getIntDelayEnabledComp(FASTCoreNet,hStartIn,hsOKDelay,tapValidIn,kernelDelay);
        heOKDelay=FASTCoreNet.addSignal(ctrlType,'hEndOutKernelDelay');
        heOKDelay.SimulinkRate=dataRate;
        pirelab.getIntDelayComp(FASTCoreNet,hEndIn,heOKDelay,kernelDelay);

        pirelab.getUnitDelayEnabledResettableComp(FASTCoreNet,hEndIn,validREG,hEndIn,heOKDelay,'validREG',0,'',true,'',-1,true);

        vsOKDelay=FASTCoreNet.addSignal(ctrlType,'vStartOutKernelDelay');
        vsOKDelay.SimulinkRate=dataRate;
        pirelab.getIntDelayEnabledComp(FASTCoreNet,vStartIn,vsOKDelay,tapValidIn,kernelDelay);
        veOKDelay=FASTCoreNet.addSignal(ctrlType,'vEndOutKernelDelay');
        veOKDelay.SimulinkRate=dataRate;
        pirelab.getIntDelayComp(FASTCoreNet,vEndIn,veOKDelay,kernelDelay);
        vlOKDelay=FASTCoreNet.addSignal(ctrlType,'validOutKernelDelay');
        vlOKDelay.SimulinkRate=dataRate;
        validEnbDelay=FASTCoreNet.addSignal(ctrlType,'validEnbDelay');
        validEnbDelay.SimulinkRate=dataRate;
        pirelab.getIntDelayEnabledResettableComp(FASTCoreNet,validIn,validEnbDelay,tapValidIn,hEndIn,kernelDelay);

        pirelab.getLogicComp(FASTCoreNet,[validEnbDelay,validREG],vlOKDelay,'or');

        processOREndLine=FASTCoreNet.addSignal(ctrlType,'processOREndLine');
        processOREndLine.SimulinkRate=dataRate;
        pirelab.getLogicComp(FASTCoreNet,[tapValidIn,validREG],processOREndLine,'or');

        pirelab.getLogicComp(FASTCoreNet,[hsOKDelay,processOREndLine],hStartDly,'and');
        pirelab.getLogicComp(FASTCoreNet,[heOKDelay,processOREndLine],hEndDly,'and');
        pirelab.getLogicComp(FASTCoreNet,[vsOKDelay,processOREndLine],vStartDly,'and');
        pirelab.getLogicComp(FASTCoreNet,[veOKDelay,processOREndLine],vEndDly,'and');
        pirelab.getLogicComp(FASTCoreNet,[vlOKDelay,processOREndLine],validDly,'and');
    else

        hsOKDelay=FASTCoreNet.addSignal(ctrlType,'hStartOutKernelDelay');
        hsOKDelay.SimulinkRate=dataRate;
        pirelab.getIntDelayEnabledComp(FASTCoreNet,hStartIn,hsOKDelay,tapValidIn,kernelDelay);
        heOKDelay=FASTCoreNet.addSignal(ctrlType,'hEndOutKernelDelay');
        heOKDelay.SimulinkRate=dataRate;
        pirelab.getIntDelayEnabledComp(FASTCoreNet,hEndIn,heOKDelay,tapValidIn,kernelDelay);
        vsOKDelay=FASTCoreNet.addSignal(ctrlType,'vStartOutKernelDelay');
        vsOKDelay.SimulinkRate=dataRate;
        pirelab.getIntDelayEnabledComp(FASTCoreNet,vStartIn,vsOKDelay,tapValidIn,kernelDelay);
        veOKDelay=FASTCoreNet.addSignal(ctrlType,'vEndOutKernelDelay');
        veOKDelay.SimulinkRate=dataRate;
        pirelab.getIntDelayEnabledComp(FASTCoreNet,vEndIn,veOKDelay,tapValidIn,kernelDelay);
        vlOKDelay=FASTCoreNet.addSignal(ctrlType,'validOutKernelDelay');
        vlOKDelay.SimulinkRate=dataRate;
        pirelab.getIntDelayEnabledComp(FASTCoreNet,validIn,vlOKDelay,tapValidIn,kernelDelay);

        pirelab.getLogicComp(FASTCoreNet,[hsOKDelay,tapValidIn],hStartDly,'and');
        pirelab.getLogicComp(FASTCoreNet,[heOKDelay,tapValidIn],hEndDly,'and');
        pirelab.getLogicComp(FASTCoreNet,[vsOKDelay,tapValidIn],vStartDly,'and');
        pirelab.getLogicComp(FASTCoreNet,[veOKDelay,tapValidIn],vEndDly,'and');
        pirelab.getLogicComp(FASTCoreNet,[vlOKDelay,tapValidIn],validDly,'and');
    end





    pirelab.getDTCComp(FASTCoreNet,tapOutSigFlat(8),hCastA,'floor','wrap');
    pirelab.getDTCComp(FASTCoreNet,tapOutSigFlat(2),hCastB,'floor','wrap');

    pirelab.getDTCComp(FASTCoreNet,tapOutSigFlat(6),vCastA,'floor','wrap');
    pirelab.getDTCComp(FASTCoreNet,tapOutSigFlat(4),vCastB,'floor','wrap');

    pirelab.getSubComp(FASTCoreNet,[hCastA,hCastB],horizSub);
    pirelab.getSubComp(FASTCoreNet,[vCastA,vCastB],vertSub);

    pirelab.getUnitDelayComp(FASTCoreNet,horizSub,horizReg);
    pirelab.getUnitDelayComp(FASTCoreNet,vertSub,vertReg);


    createPipeMul(FASTCoreNet,[horizReg,horizReg],xSquared,dataRate);
    createPipeMul(FASTCoreNet,[vertReg,vertReg],ySquared,dataRate);
    createPipeMul(FASTCoreNet,[horizReg,vertReg],xy,dataRate);

    hStartDlyPipe=FASTCoreNet.addSignal(ctrlType,'hStartDlyPipe');
    hEndDlyPipe=FASTCoreNet.addSignal(ctrlType,'hEndDlyPipe');
    vStartDlyPipe=FASTCoreNet.addSignal(ctrlType,'vStartDlyPipe');
    vEndDlyPipe=FASTCoreNet.addSignal(ctrlType,'vEndDlyPipe');
    validDlyPipe=FASTCoreNet.addSignal(ctrlType,'validDlyPipe');
    hStartDlyPipe.SimulinkRate=dataRate;
    hEndDlyPipe.SimulinkRate=dataRate;
    vStartDlyPipe.SimulinkRate=dataRate;
    vEndDlyPipe.SimulinkRate=dataRate;
    validDlyPipe.SimulinkRate=dataRate;


    pirelab.getIntDelayComp(FASTCoreNet,hStartDly,hStartDlyPipe,5);
    pirelab.getIntDelayComp(FASTCoreNet,hEndDly,hEndDlyPipe,5);
    pirelab.getIntDelayComp(FASTCoreNet,vStartDly,vStartDlyPipe,5);
    pirelab.getIntDelayComp(FASTCoreNet,vEndDly,vEndDlyPipe,5);
    pirelab.getIntDelayComp(FASTCoreNet,validDly,validDlyPipe,5);



    filtAOut=FASTCoreNet.addSignal(mulType,'filtAOut');
    filtBOut=FASTCoreNet.addSignal(mulType,'filtBOut');
    filtCOut=FASTCoreNet.addSignal(mulType,'filtCOut');
    filtAOut.SimulinkRate=dataRate;
    filtBOut.SimulinkRate=dataRate;
    filtCOut.SimulinkRate=dataRate;

    hStartA=FASTCoreNet.addSignal(ctrlType,'hStartA');
    hEndA=FASTCoreNet.addSignal(ctrlType,'hEndA');
    vStartA=FASTCoreNet.addSignal(ctrlType,'vStartA');
    vEndA=FASTCoreNet.addSignal(ctrlType,'vEndA');
    validA=FASTCoreNet.addSignal(ctrlType,'validA');
    hStartA.SimulinkRate=dataRate;
    hEndA.SimulinkRate=dataRate;
    vStartA.SimulinkRate=dataRate;
    vEndA.SimulinkRate=dataRate;
    validA.SimulinkRate=dataRate;

    hStartB=FASTCoreNet.addSignal(ctrlType,'hStartB');
    hEndB=FASTCoreNet.addSignal(ctrlType,'hEndB');
    vStartB=FASTCoreNet.addSignal(ctrlType,'vStartB');
    vEndB=FASTCoreNet.addSignal(ctrlType,'vEndB');
    validB=FASTCoreNet.addSignal(ctrlType,'validB');
    hStartB.SimulinkRate=dataRate;
    hEndB.SimulinkRate=dataRate;
    vStartB.SimulinkRate=dataRate;
    vEndB.SimulinkRate=dataRate;
    validB.SimulinkRate=dataRate;

    hStartC=FASTCoreNet.addSignal(ctrlType,'hStartC');
    hEndC=FASTCoreNet.addSignal(ctrlType,'hEndC');
    vStartC=FASTCoreNet.addSignal(ctrlType,'vStartC');
    vEndC=FASTCoreNet.addSignal(ctrlType,'vEndC');
    validC=FASTCoreNet.addSignal(ctrlType,'validC');
    hStartC.SimulinkRate=dataRate;
    hEndC.SimulinkRate=dataRate;
    vStartC.SimulinkRate=dataRate;
    vEndC.SimulinkRate=dataRate;
    validC.SimulinkRate=dataRate;

    cSign=false;
    cWL=16;
    cFL=19;

    filtBlockInfo.Coefficients=[0.0178422039268339,0.0306173443749486,0.0366556162983683,0.0306173443749486,0.0178422039268339;...
    0.0306173443749486,0.0525395730492887,0.0629012891056152,0.0525395730492887,0.0306173443749486;...
    0.0366556162983683,0.0629012891056152,0.0753065154799872,0.0629012891056152,0.0366556162983683;...
    0.0306173443749486,0.0525395730492887,0.0629012891056152,0.0525395730492887,0.0306173443749486;...
    0.0178422039268339,0.0306173443749486,0.0366556162983683,0.0306173443749486,0.0178422039268339];

    [filtBlockInfo.KernelHeight,filtBlockInfo.KernelWidth]=size(filtBlockInfo.Coefficients);
    filtBlockInfo.coeffFromPort=false;
    filtBlockInfo.PaddingMethodString='Replicate';
    filtBlockInfo.PaddingMethod=1;
    filtBlockInfo.PaddingValue=0;
    filtBlockInfo.LineBufferSize=blockInfo.LineBufferSize;
    filtBlockInfo.RoundingMethod='Nearest';
    filtBlockInfo.OverflowAction='Saturate';
    filtBlockInfo.CoefficientsDataType=2;
    filtBlockInfo.CustomCoefficientsDataType=numerictype(cSign,cWL,cFL);
    filtBlockInfo.OutputDataType=1;
    filtBlockInfo.CustomOutputDataType=[];
    filtBlockInfo.filterType=filtAOut.Type;
    filtBlockInfo.baseRate=dataRate;
    filtBlockInfo.outportCornerType=filtAOut.Type;


    filtAComp=createFilter(FASTCoreNet,'A',filtBlockInfo);
    filtBComp=createFilter(FASTCoreNet,'B',filtBlockInfo);
    filtCComp=createFilter(FASTCoreNet,'C',filtBlockInfo);

    pirelab.instantiateNetwork(FASTCoreNet,filtAComp,[xSquared,hStartDlyPipe,hEndDlyPipe,vStartDlyPipe,vEndDlyPipe,validDlyPipe],...
    [filtAOut,hStartA,hEndA,vStartA,vEndA,validA],...
    'CornerFiltANet_inst');

    pirelab.instantiateNetwork(FASTCoreNet,filtBComp,[ySquared,hStartDlyPipe,hEndDlyPipe,vStartDlyPipe,vEndDlyPipe,validDlyPipe],...
    [filtBOut,hStartB,hEndB,vStartB,vEndB,validB],...
    'CornerFiltBNet_inst');

    pirelab.instantiateNetwork(FASTCoreNet,filtCComp,[xy,hStartDlyPipe,hEndDlyPipe,vStartDlyPipe,vEndDlyPipe,validDlyPipe],...
    [filtCOut,hStartC,hEndC,vStartC,vEndC,validC],...
    'CornerFiltCNet_inst');






    metricMulType=FASTCoreNet.getType('FixedPoint','Signed',true,...
    'WordLength',4*(inWL+2)+2,...
    'FractionLength',(4*inFL));
    metricABType=FASTCoreNet.getType('FixedPoint','Signed',true,...
    'WordLength',2*(inWL+2)+1,...
    'FractionLength',2*inFL);
    metricSumType=FASTCoreNet.getType('FixedPoint','Signed',true,...
    'WordLength',4*(inWL+2)+4,...
    'FractionLength',(4*inFL));
    metricKType=FASTCoreNet.getType('FixedPoint','Signed',false,...
    'WordLength',16,...
    'FractionLength',-20);

    finalDelay=12;
    presub=FASTCoreNet.addSignal(metricSumType,'presub');
    presubreg=FASTCoreNet.addSignal(metricSumType,'presub');
    premetric=FASTCoreNet.addSignal(metricSumType,'premetric');
    metric=FASTCoreNet.addSignal(metricSumType,'metric');
    presub.SimulinkRate=dataRate;
    presubreg.SimulinkRate=dataRate;
    premetric.SimulinkRate=dataRate;
    metric.SimulinkRate=dataRate;

    AtimesB=FASTCoreNet.addSignal(metricMulType,'AtimesB');
    Csquared=FASTCoreNet.addSignal(metricMulType,'Csquared');
    AplusB=FASTCoreNet.addSignal(metricABType,'AplusB');
    ApBsq=FASTCoreNet.addSignal(metricMulType,'ApBsq');
    kApBsq=FASTCoreNet.addSignal(metricMulType,'kApBsq');
    k=FASTCoreNet.addSignal(metricKType,'k');
    AtimesB.SimulinkRate=dataRate;
    Csquared.SimulinkRate=dataRate;
    AplusB.SimulinkRate=dataRate;
    ApBsq.SimulinkRate=dataRate;
    kApBsq.SimulinkRate=dataRate;
    k.SimulinkRate=dataRate;

    pirelab.getConstComp(FASTCoreNet,k,fi(0.04,0,16,20));

    createPipeMul(FASTCoreNet,[filtAOut,filtBOut],AtimesB,dataRate);
    createPipeMul(FASTCoreNet,[filtCOut,filtCOut],Csquared,dataRate);
    finalDelay=finalDelay-4;

    pirelab.getAddComp(FASTCoreNet,[filtAOut,filtBOut],AplusB);
    createPipeMul(FASTCoreNet,[AplusB,AplusB],ApBsq,dataRate);

    createPipeMul(FASTCoreNet,[ApBsq,k],kApBsq,dataRate);
    finalDelay=finalDelay-4;

    pirelab.getSubComp(FASTCoreNet,[AtimesB,Csquared],presub);
    pirelab.getIntDelayComp(FASTCoreNet,presub,presubreg,4);
    pirelab.getSubComp(FASTCoreNet,[presubreg,kApBsq],premetric);

    pirelab.getUnitDelayComp(FASTCoreNet,premetric,metric);
    finalDelay=finalDelay-1;


    threshCompare=FASTCoreNet.addSignal(ctrlType,'threshCompare');
    greaterZero=FASTCoreNet.addSignal(ctrlType,'greaterZero');
    passMetric=FASTCoreNet.addSignal(ctrlType,'passMetric');
    passMetricReg=FASTCoreNet.addSignal(ctrlType,'passMetricReg');
    cornerConvert=FASTCoreNet.addSignal(cornerOutType,'cornerConvert');
    cornerConvertReg=FASTCoreNet.addSignal(cornerOutType,'cornerConvertReg');
    cornerpreout=FASTCoreNet.addSignal(cornerOutType,'cornerpreout');
    zerooutconst=FASTCoreNet.addSignal(cornerOutType,'cornerzero');
    metriczeroconst=FASTCoreNet.addSignal(metricSumType,'metriczero');
    threshCompare.SimulinkRate=dataRate;
    greaterZero.SimulinkRate=dataRate;
    passMetric.SimulinkRate=dataRate;
    passMetricReg.SimulinkRate=dataRate;
    cornerConvert.SimulinkRate=dataRate;
    cornerConvertReg.SimulinkRate=dataRate;
    cornerpreout.SimulinkRate=dataRate;
    zerooutconst.SimulinkRate=dataRate;
    metriczeroconst.SimulinkRate=dataRate;

    pirelab.getConstComp(FASTCoreNet,zerooutconst,0);
    pirelab.getConstComp(FASTCoreNet,metriczeroconst,0);

    pirelab.getDTCComp(FASTCoreNet,metric,cornerConvert,...
    blockInfo.RoundingMethod,blockInfo.OverflowAction);
    pirelab.getRelOpComp(FASTCoreNet,[cornerConvert,minContrastSig],threshCompare,'>');
    pirelab.getRelOpComp(FASTCoreNet,[metric,metriczeroconst],greaterZero,'>');
    pirelab.getLogicComp(FASTCoreNet,[threshCompare,greaterZero],passMetric,'and');

    pirelab.getUnitDelayComp(FASTCoreNet,cornerConvert,cornerConvertReg);
    pirelab.getUnitDelayComp(FASTCoreNet,passMetric,passMetricReg);
    finalDelay=finalDelay-1;
    pirelab.getSwitchComp(FASTCoreNet,[cornerConvertReg,zerooutconst],cornerpreout,passMetricReg,'','==',1);

    pirelab.getIntDelayComp(FASTCoreNet,cornerpreout,cornerOut,finalDelay);
    finalCtrlDelay=2;
    pirelab.getIntDelayComp(FASTCoreNet,hStartA,hStartOut,finalCtrlDelay);
    pirelab.getIntDelayComp(FASTCoreNet,hEndA,hEndOut,finalCtrlDelay);
    pirelab.getIntDelayComp(FASTCoreNet,vStartA,vStartOut,finalCtrlDelay);
    pirelab.getIntDelayComp(FASTCoreNet,vEndA,vEndOut,finalCtrlDelay);
    pirelab.getIntDelayComp(FASTCoreNet,validA,validOut,finalCtrlDelay);

end


function createPipeMul(net,inputs,output,dataRate,inputpipedepth,outputpipedepth)
    if nargin==4
        inputpipedepth=2;
        outputpipedepth=2;
    elseif nargin==5
        outputpipedepth=2;
    end

    if inputpipedepth>0
        Atype=inputs(1).Type;
        Btype=inputs(2).Type;
        pipeA=net.addSignal(Atype,'pipeA');
        pipeB=net.addSignal(Btype,'pipeB');
        pipeA.SimulinkRate=dataRate;
        pipeB.SimulinkRate=dataRate;

        pirelab.getIntDelayComp(net,inputs(1),pipeA,inputpipedepth);
        pirelab.getIntDelayComp(net,inputs(2),pipeB,inputpipedepth);
    end
    if outputpipedepth>0
        Ctype=output.Type;
        pipeC=net.addSignal(Ctype,'pipeC');
        pipeC.SimulinkRate=dataRate;

        pirelab.getIntDelayComp(net,pipeC,output,outputpipedepth);
    end

    if inputpipedepth==0&&outputpipedepth==0
        pirelab.getMulComp(net,inputs,output);
    elseif inputpipedepth==0
        pirelab.getMulComp(net,inputs,pipeC);
    elseif outputpipedepth==0
        pirelab.getMulComp(net,[pipeA,pipeB],output);
    else
        pirelab.getMulComp(net,[pipeA,pipeB],pipeC);
    end
end




















function topNet=createFilter(FASTCoreNet,name,blockInfo)
    ctrlType=pir_boolean_t();
    topNet=pirelab.createNewNetwork(...
    'Network',FASTCoreNet,...
    'Name',['HarrisFilter',name],...
    'InportNames',{[name,'In'],'hStart','hEnd','vStart','vEnd','valid'},...
    'InportTypes',[blockInfo.filterType,ctrlType,ctrlType,ctrlType,ctrlType,ctrlType],...
    'InportRates',[blockInfo.baseRate,blockInfo.baseRate,blockInfo.baseRate,...
    blockInfo.baseRate,blockInfo.baseRate,blockInfo.baseRate],...
    'OutportNames',{['filter',name,'out'],'hStartOut','hEndOut','vStartOut','vEndOut','validOut'},...
    'OutportTypes',[blockInfo.outportCornerType,ctrlType,ctrlType,ctrlType,ctrlType,ctrlType]);

    topNet.addComment(['Image Filter ',name]);


    [inSig,outSig]=visionhdlsupport.internal.expandpixelcontrolbus(topNet);

    inportnames{1}='dataIn';
    inportnames{2}='hStartIn';
    inportnames{3}='hEndIn';
    inportnames{4}='vStartIn';
    inportnames{5}='vEndIn';
    inportnames{6}='validIn';
    if blockInfo.coeffFromPort
        inportnames{6}='coeffIn';
    end

    outportnames{1}='dataOut';
    outportnames{2}='hStartOut';
    outportnames{3}='hEndOut';
    outportnames{4}='vStartOut';
    outportnames{5}='vEndOut';
    outportnames{6}='validOut';


    for ii=1:numel(inportnames)
        inSig(ii).Name=inportnames{ii};
    end
    for ii=1:numel(outportnames)
        outSig(ii).Name=outportnames{ii};
    end


    this=visionhdlsupport.internal.ImageFilter;
    this.elaborateImageFilter(topNet,blockInfo,inSig,outSig);
end
