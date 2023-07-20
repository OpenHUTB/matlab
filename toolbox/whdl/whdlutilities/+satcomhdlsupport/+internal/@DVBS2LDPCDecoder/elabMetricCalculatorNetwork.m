function mNet=elabMetricCalculatorNetwork(this,topNet,blockInfo,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    ufix5Type=pir_ufixpt_t(5,0);
    ufix6Type=pir_ufixpt_t(6,0);
    layType=pir_ufixpt_t(blockInfo.layWL,0);
    aType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    alphaVType=pirelab.getPirVectorType(aType,blockInfo.memDepth);

    bcomp1Type=pirelab.getPirVectorType(pir_ufixpt_t(blockInfo.betadecmpWL,0),blockInfo.memDepth);
    bcomp2Type=pirelab.getPirVectorType(pir_ufixpt_t(2*blockInfo.minWL,0),blockInfo.memDepth);


    mNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','MetricCalculator',...
    'Inportnames',{'data','valid','shift','reset','ddsm','parvalid','layeridx','betaenb','degree'},...
    'InportTypes',[alphaVType,ufix1Type,ufix6Type,ufix1Type,ufix1Type,ufix1Type,layType,ufix1Type,ufix5Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'gamma','gammavalid','gParValid','fData'},...
    'OutportTypes',[alphaVType,ufix1Type,ufix1Type,alphaVType]...
    );



    data=mNet.PirInputSignals(1);
    valid=mNet.PirInputSignals(2);
    shift=mNet.PirInputSignals(3);
    reset=mNet.PirInputSignals(4);
    ddsm=mNet.PirInputSignals(5);
    parvalid=mNet.PirInputSignals(6);
    layeridx=mNet.PirInputSignals(7);
    betaenb=mNet.PirInputSignals(8);
    degree=mNet.PirInputSignals(9);

    gamma=mNet.PirOutputSignals(1);
    validout=mNet.PirOutputSignals(2);
    gparvalid=mNet.PirOutputSignals(3);
    fpdata=mNet.PirOutputSignals(4);



    sdata=mNet.addSignal(alphaVType,'sData');
    svalid=mNet.addSignal(ufix1Type,'sValid');

    c1Net=this.elabCircularShifterNetwork(mNet,blockInfo,dataRate);
    c1Net.addComment(['Circular_Shifter_Unit_',num2str(1)]);
    pirelab.instantiateNetwork(mNet,c1Net,[data,valid,shift],...
    [sdata,svalid],['Circular_Shifter_Unit_',num2str(1)]);


    fdata=mNet.addSignal(alphaVType,'fData');
    fvalid=mNet.addSignal(ufix1Type,'fValid');

    betacomp1=mNet.addSignal(bcomp1Type,'betaDecomp1');
    betacomp2=mNet.addSignal(bcomp2Type,'betaDecomp2');
    betavalid=mNet.addSignal(ufix1Type,'betaValid');

    cnucomp1=mNet.addSignal(bcomp1Type,'cnuDecomp1');
    cnucomp2=mNet.addSignal(bcomp2Type,'cnuDecomp2');
    cnuvalid=mNet.addSignal(ufix1Type,'cnuValid');

    fNet=this.elabFunctionalUnitNetwork(mNet,blockInfo,dataRate);
    fNet.addComment('Functional Unit');
    pirelab.instantiateNetwork(mNet,fNet,[sdata,svalid,degree,cnucomp1,...
    cnucomp2,cnuvalid,reset,ddsm],[fdata,fvalid,betacomp1,betacomp2,...
    betavalid],'Functional Unit');


    valid_reg=mNet.addSignal(ufix1Type,'validReg');
    pirelab.getUnitDelayComp(mNet,valid,valid_reg,'',0);
    valid_reg_neg=mNet.addSignal(ufix1Type,'validRegNeg');
    pirelab.getLogicComp(mNet,valid_reg,valid_reg_neg,'not');
    rdenb_tmp=mNet.addSignal(ufix1Type,'rdEnbTmp');
    pirelab.getLogicComp(mNet,[valid,valid_reg_neg],rdenb_tmp,'and');

    rdenb=mNet.addSignal(ufix1Type,'rdEnb');
    pirelab.getLogicComp(mNet,[betaenb,rdenb_tmp],rdenb,'and');

    bmNet=this.elabBetaMemoryNetwork(mNet,blockInfo,dataRate);
    bmNet.addComment('Check Node RAM');
    pirelab.instantiateNetwork(mNet,bmNet,[betacomp1,betacomp2,layeridx,...
    rdenb,betavalid],[cnucomp1,cnucomp2,cnuvalid],'Check Node RAM');



    shift_reg=mNet.addSignal(shift.Type,'shiftReg');
    shift_val=mNet.addSignal(shift.Type,'shiftVal');
    const=mNet.addSignal(shift.Type,'const45');
    pirelab.getConstComp(mNet,const,45);
    pirelab.getSubComp(mNet,[const,shift_reg],shift_val,'Floor','Wrap','Sub_Comp1');

    c2Net=this.elabCircularShifterNetwork(mNet,blockInfo,dataRate);
    c2Net.addComment(['Circular_Shifter_Unit_',num2str(2)]);
    pirelab.instantiateNetwork(mNet,c2Net,[fdata,fvalid,shift_val],...
    [gamma,validout],['Circular_Shifter_Unit_',num2str(2)]);

    pirelab.getUnitDelayComp(mNet,fdata,fpdata,'',0);


    wrenb_reg=mNet.addSignal(ufix1Type,'wrEnbReg');
    parvalidD=mNet.addSignal(ufix1Type,'parValidD');


    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+satcomhdlsupport','+internal','@DVBS2LDPCDecoder','cgireml','variableDelay.m'),'r');
    variableDelay=fread(fid,Inf,'char=>char');
    fclose(fid);

    wraddr=mNet.addSignal(ufix5Type,'wrAddr');
    rdaddr=mNet.addSignal(ufix5Type,'rdAddr');
    wrenb=mNet.addSignal(ufix1Type,'wrEnb');

    mNet.addComponent2(...
    'kind','cgireml',...
    'Name','variableDelay',...
    'InputSignals',[valid,fvalid],...
    'OutputSignals',[wraddr,wrenb,rdaddr],...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','variableDelay',...
    'EMLFileBody',variableDelay,...
    'EMLFlag_TreatInputIntsAsFixpt',true);

    pirelab.getUnitDelayComp(mNet,wrenb,wrenb_reg,'',0);

    pirelab.getSimpleDualPortRamComp(mNet,[shift,wraddr,wrenb,rdaddr],shift_reg,'VariableDelayShift',1,-1,[],'','');
    pirelab.getSimpleDualPortRamComp(mNet,[parvalid,wraddr,wrenb_reg,rdaddr],parvalidD,'VariableDelayParity',1,-1,[],'','');

    pirelab.getUnitDelayComp(mNet,parvalidD,gparvalid,'',0);


end