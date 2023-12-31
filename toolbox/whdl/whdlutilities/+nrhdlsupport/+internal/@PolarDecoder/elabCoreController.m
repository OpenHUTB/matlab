function coreControlNet=elabCoreController(this,topNet,blockInfo,dataRate)
    boolType=pir_boolean_t();
    nMax=blockInfo.nMax;
    coreOrder=blockInfo.coreOrder;
    stageType=blockInfo.stageType;
    NType=blockInfo.NType;
    pathType=blockInfo.pathType;
    blockType=blockInfo.blockType;
    listLength=blockInfo.listLength;
    betaPathType=pirelab.createPirArrayType(pathType,[1,nMax]);
    contPathsType=pirelab.createPirArrayType(pathType,[1,listLength]);

    inportNames={'startIn_reg','startDecode','nSub1','NSub1','F','newActvPathCnt'};
    inTypes=[boolType,boolType,stageType,NType,boolType,pathType];
    indataRates=dataRate*ones(1,length(inportNames));

    outportNames={'decWrStage','decWrBlock','decLowerWrEn','decUpperWrEn','rdStage','rdBlock','makeDec',...
    'wrPath','activePathCnt','mode','betaSrc','startOutput','leafIdx','alphaUpdateWrEn','betaUpdateWrEn','dupPtrWrEn'};
    outTypes=[stageType,blockType,boolType,boolType,stageType,blockType,boolType,...
    pathType,pathType,boolType,boolType,boolType,NType,boolType,boolType,boolType];

    coreControlNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','coreController',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );


    desc='coreController - control the operation of core,tree memory and decisions';

    fid=fopen(fullfile(blockInfo.emlPath,'coreController.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char');
    fclose(fid);

    inports=coreControlNet.PirInputSignals;
    outports=coreControlNet.PirOutputSignals;

    coreCtrl=coreControlNet.addComponent2(...
    'kind','cgireml',...
    'Name','coreController',...
    'InputSignals',inports,...
    'OutputSignals',outports,...
    'EMLFileName','coreController',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{coreOrder,listLength,nMax},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc...
    );
    coreCtrl.runConcurrencyMaximizer(0);
end