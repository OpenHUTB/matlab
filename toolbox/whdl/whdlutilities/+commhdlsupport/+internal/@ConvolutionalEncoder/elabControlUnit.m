function ctrlNet=elabControlUnit(~,topNet,blockInfo,dataRate)

    ufix1Type=pir_ufixpt_t(1,0);
    inportnames={'startIn','endIn','validIn'};
    inporttypes=[ufix1Type,ufix1Type,ufix1Type];
    inportrates=[dataRate,dataRate,dataRate];

    if strcmpi(blockInfo.operationMode,'Terminated')
        OutportTypes=[ufix1Type,ufix1Type,ufix1Type,ufix1Type];
        OutportNames={'rstSig','endSig','enbSig','tailFlag'};

    else
        OutportTypes=[ufix1Type,ufix1Type,ufix1Type];
        OutportNames={'rstSig','endSig','enbSig'};
    end

    ctrlNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','controlUnit',...
    'InportNames',inportnames,...
    'InportTypes',inporttypes,...
    'InportRates',inportrates,...
    'OutportNames',OutportNames,...
    'OutportTypes',OutportTypes...
    );

    startin=ctrlNet.PirInputSignals(1);
    endin=ctrlNet.PirInputSignals(2);
    validin=ctrlNet.PirInputSignals(3);


    rstSig=ctrlNet.PirOutputSignals(1);
    endSig=ctrlNet.PirOutputSignals(2);
    enbSig=ctrlNet.PirOutputSignals(3);


    if strcmpi(blockInfo.operationMode,'Terminated')
        tailflag=ctrlNet.PirOutputSignals(4);
    end


    startinFlag=ctrlNet.addSignal(ufix1Type,'startinFlag');
    pirelab.getLogicComp(ctrlNet,[startin,validin],startinFlag,'and');
    startOutCmp=pirelab.getUnitDelayComp(ctrlNet,startinFlag,rstSig,'rstSig',0);
    startOutCmp.addComment('reset signal of frame');

    enbStart=ctrlNet.addSignal(ufix1Type,'enbStart');
    enbStarttmp=ctrlNet.addSignal(ufix1Type,'enbStarttmp');
    enbStartReg=ctrlNet.addSignal(ufix1Type,'enbStartReg');


    pirelab.getLogicComp(ctrlNet,[startinFlag,enbStartReg],enbStart,'or');
    endSigtmp=ctrlNet.addSignal(ufix1Type,'endSigtmp');
    negendSigtmp=ctrlNet.addSignal(ufix1Type,'negendSigtmp');
    pirelab.getLogicComp(ctrlNet,endSigtmp,negendSigtmp,'not');
    pirelab.getLogicComp(ctrlNet,[negendSigtmp,enbStart],enbStarttmp,'and');
    enablestartCmp=pirelab.getUnitDelayComp(ctrlNet,enbStarttmp,enbStartReg,'enbStartReg',0);
    enablestartCmp.addComment('internal flag for enabling the frame controls');

    startProcess=ctrlNet.addSignal(ufix1Type,'startProcess');
    enbFrameEndOp=ctrlNet.addSignal(ufix1Type,'enbFrameEndOp');


    if~strcmpi(blockInfo.operationMode,'Terminated')
        pirelab.getLogicComp(ctrlNet,[validin,enbStart],startProcess,'and');
    else
        tmp=ctrlNet.addSignal(ufix1Type,'tmp');
        pirelab.getLogicComp(ctrlNet,[enbFrameEndOp,validin],tmp,'or');
        pirelab.getLogicComp(ctrlNet,[tmp,enbStart],startProcess,'and');
    end


    enbSigCmp=pirelab.getUnitDelayComp(ctrlNet,startProcess,enbSig,'startProcess',0);
    enbSigCmp.addComment('enable signal to process the frame data');


    negstart=ctrlNet.addSignal(ufix1Type,'negstart');
    pirelab.getLogicComp(ctrlNet,startin,negstart,'not');
    enbFramEndOptmp=ctrlNet.addSignal(ufix1Type,'enbFramEndOptmp');

    if~strcmpi(blockInfo.operationMode,'Terminated')

        negframeOp=ctrlNet.addSignal(ufix1Type,'negframeOp');
        pirelab.getLogicComp(ctrlNet,enbFrameEndOp,negframeOp,'not');
        negstartNend=ctrlNet.addSignal(ufix1Type,'negstartNend');
        pirelab.getLogicComp(ctrlNet,[negstart,endin],negstartNend,'and');


        andOper=[negstartNend,validin,negframeOp];
        pirelab.getBitwiseOpComp(ctrlNet,andOper,endSigtmp,'AND');


        frameEndComp=pirelab.getUnitDelayEnabledComp(ctrlNet,negstartNend,enbFrameEndOp,...
        validin,'enbFrameEndOp',0);
        frameEndComp.addComment('frameEndComp flag for frame endout operations');
    else
        negstartinflag=ctrlNet.addSignal(ufix1Type,'negstartinflag');
        pirelab.getLogicComp(ctrlNet,startinFlag,negstartinflag,'not');
        frameGapValid=ctrlNet.addSignal(ufix1Type,'frameGapValid');



        pirelab.getLogicComp(ctrlNet,[enbFrameEndOp,negstartinflag],frameGapValid,'and');
        tailflagCmp=pirelab.getUnitDelayComp(ctrlNet,frameGapValid,tailflag,'tailflag',0);
        tailflagCmp.addComment('flag to enable the appending of tail bits');


        cntType=pir_ufixpt_t(floor(log2(blockInfo.tailCount))+1,0);
        cntReg=ctrlNet.addSignal(cntType,'cntReg');
        cntCmp=pirelab.getCounterComp(ctrlNet,[startinFlag,enbFrameEndOp],cntReg,'Count limited',...
        0,1,blockInfo.tailCount,...
        true,false,true,false,...
        'counter');
        cntCmp.addComment('counts upto tail length')


        tailend=ctrlNet.addSignal(ufix1Type,'tailend');
        pirelab.getCompareToValueComp(ctrlNet,cntReg,tailend,'==',blockInfo.tailCount);



        andOper=[frameGapValid,tailend];
        pirelab.getBitwiseOpComp(ctrlNet,andOper,endSigtmp,'AND');


        negtailend=ctrlNet.addSignal(ufix1Type,'negtailend');
        pirelab.getLogicComp(ctrlNet,tailend,negtailend,'not');

        enbFramEndOpsel0=ctrlNet.addSignal(ufix1Type,'enbFramEndOpsel0');
        enbFramEndOpsel1=ctrlNet.addSignal(ufix1Type,'enbFramEndOpsel1');

        pirelab.getSwitchComp(ctrlNet,[enbFramEndOpsel0,enbFramEndOpsel1],enbFramEndOptmp,...
        validin,'','~=',0);

        frameEndComp=pirelab.getUnitDelayComp(ctrlNet,enbFramEndOptmp,enbFrameEndOp,...
        'enbFrameEndOp',0);
        frameEndComp.addComment('frameEndComp flag for frame endout operations');

        tmp1=ctrlNet.addSignal(ufix1Type,'tmp1');

        andOper1=[negstart,negtailend,tmp1];
        pirelab.getLogicComp(ctrlNet,[enbFrameEndOp,endin],tmp1,'or');
        pirelab.getBitwiseOpComp(ctrlNet,andOper1,enbFramEndOpsel0,'AND');
        pirelab.getLogicComp(ctrlNet,[enbFrameEndOp,negtailend],enbFramEndOpsel1,'and');
    end
    endSigCmp=pirelab.getUnitDelayComp(ctrlNet,endSigtmp,endSig,'endSig',0);
    endSigCmp.addComment('end out signal of frame')
end