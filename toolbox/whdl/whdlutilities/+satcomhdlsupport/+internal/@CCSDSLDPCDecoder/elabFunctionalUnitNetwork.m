function fNet=elabFunctionalUnitNetwork(this,topNet,blockInfo,dataRate)





    ufix1Type=pir_boolean_t;
    cType=pir_ufixpt_t(blockInfo.vaddrWL,0);
    bType=pir_sfixpt_t(blockInfo.betaWL,blockInfo.alphaFL);
    aType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    bcType=pir_ufixpt_t(blockInfo.betaCompWL,0);
    bcType3=pir_ufixpt_t(blockInfo.betaIdxWL,0);
    bcType4=pir_ufixpt_t(2*blockInfo.minWL,0);
    vType=pir_ufixpt_t(blockInfo.vWL,0);

    betaVType=pirelab.getPirVectorType(bType,blockInfo.memDepth);
    alphaVType=pirelab.getPirVectorType(aType,blockInfo.memDepth);
    bcVType=pirelab.getPirVectorType(bcType,blockInfo.memDepth);
    bcVType3=pirelab.getPirVectorType(bcType3,blockInfo.memDepth);
    bcVType4=pirelab.getPirVectorType(bcType4,blockInfo.memDepth);
    eVType=pirelab.getPirVectorType(ufix1Type,blockInfo.memDepth);


    fNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','FunctionalUnit',...
    'Inportnames',{'data','valid','count','rdEnb','bcomp1','bcomp2','bcomp3','bcomp4','bValid','reset','shift'},...
    'InportTypes',[alphaVType,ufix1Type,cType,eVType,bcVType,bcVType,bcVType3,bcVType4,ufix1Type,ufix1Type,vType],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'gamma','valid','ccomp1','ccomp2','ccomp3','ccomp4','cValid','shiftOut','rdEnbOut'},...
    'OutportTypes',[alphaVType,ufix1Type,bcVType,bcVType,bcVType3,bcVType4,ufix1Type,vType,eVType]...
    );



    data=fNet.PirInputSignals(1);
    valid=fNet.PirInputSignals(2);
    count=fNet.PirInputSignals(3);
    rdenable=fNet.PirInputSignals(4);
    betacomp1=fNet.PirInputSignals(5);
    betacomp2=fNet.PirInputSignals(6);
    betacomp3=fNet.PirInputSignals(7);
    betacomp4=fNet.PirInputSignals(8);
    betavalid=fNet.PirInputSignals(9);
    reset=fNet.PirInputSignals(10);
    shift=fNet.PirInputSignals(11);

    gamma=fNet.PirOutputSignals(1);
    validout=fNet.PirOutputSignals(2);
    cdecomp1=fNet.PirOutputSignals(3);
    cdecomp2=fNet.PirOutputSignals(4);
    cdecomp3=fNet.PirOutputSignals(5);
    cdecomp4=fNet.PirOutputSignals(6);
    cvalid=fNet.PirOutputSignals(7);
    shiftout=fNet.PirOutputSignals(8);
    rdenbout=fNet.PirOutputSignals(9);

    beta=fNet.addSignal(betaVType,'beta1');
    bvalid=fNet.addSignal(ufix1Type,'betaValid1');

    cnucomp1=fNet.addSignal(cdecomp1.Type,'cnuDecomp1');
    cnucomp2=fNet.addSignal(cdecomp2.Type,'cnuDecomp2');
    cnucomp3=fNet.addSignal(cdecomp3.Type,'cnuDecomp3');
    cnucomp4=fNet.addSignal(cdecomp4.Type,'cnuDecomp4');
    cnuvalid=fNet.addSignal(ufix1Type,'cnuValid');

    rdenb_delay=fNet.addSignal(rdenbout.Type,'rdEnbDelay');
    pirelab.getUnitDelayComp(fNet,rdenable,rdenb_delay,'rdEnb',0);



    b1Net=this.elabBetaDecompressNetwork(fNet,blockInfo,dataRate);
    b1Net.addComment(['Beta_Decompress_Unit_',num2str(1)]);
    pirelab.instantiateNetwork(fNet,b1Net,[betacomp1,betacomp2,betacomp3,betacomp4,betavalid,count,reset,rdenb_delay],...
    [beta,bvalid],['Beta_Decompress_Unit_',num2str(1)]);

    alpha=fNet.addSignal(alphaVType,'alpha');
    alphaD=fNet.addSignal(alphaVType,'alphaD');
    valid_alpha=fNet.addSignal(ufix1Type,'alphaValid');



    vNet=this.elabVariableNodeUnitNetwork(fNet,blockInfo,dataRate);
    vNet.addComment('Variable Node Unit');
    pirelab.instantiateNetwork(fNet,vNet,[data,beta,valid,bvalid,reset],...
    [alpha,valid_alpha],'Variable Node Unit');


    alpha_dtc=fNet.addSignal(betaVType,'alphaDTC');
    pirelab.getDTCComp(fNet,alpha,alpha_dtc,'Floor','Saturate');



    cNet=this.elabCheckNodeUnitNetwork(fNet,blockInfo,dataRate);
    cNet.addComment('Check Node Unit');
    pirelab.instantiateNetwork(fNet,cNet,[alpha_dtc,valid_alpha,count,reset,rdenb_delay],...
    [cnucomp1,cnucomp2,cnucomp3,cnucomp4,cnuvalid],'Check Node Unit');

    beta1=fNet.addSignal(betaVType,'beta2');
    bvalid1=fNet.addSignal(ufix1Type,'betaValid2');

    rdenb_reg=fNet.addSignal(rdenbout.Type,'rdEnbReg');


    b2Net=this.elabBetaDecompressNetwork(fNet,blockInfo,dataRate);
    b2Net.addComment(['Beta_Decompress_Unit_',num2str(2)]);
    pirelab.instantiateNetwork(fNet,b2Net,[cnucomp1,cnucomp2,cnucomp3,cnucomp4,cnuvalid,count,reset,rdenb_reg],...
    [beta1,bvalid1],['Beta_Decompress_Unit_',num2str(2)]);



    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+satcomhdlsupport','+internal','@CCSDSLDPCDecoder','cgireml','addressGeneration.m'),'r');
    addressGeneration=fread(fid,Inf,'char=>char');
    fclose(fid);

    wraddr=fNet.addSignal(cType,'wrAddr');
    rdaddr=fNet.addSignal(cType,'rdAddr');
    rdaddr_rd=fNet.addSignal(cType,'rdAddrEnb');
    rdvalid=fNet.addSignal(ufix1Type,'rdValid');
    rdvalidreg=fNet.addSignal(ufix1Type,'rdValidReg');
    shiftout_reg=fNet.addSignal(shiftout.Type,'shiftOutReg');
    shift_reg=fNet.addSignal(shiftout.Type,'shiftReg');
    wraddr_enb=fNet.addSignal(cType,'wrAddrEnb');
    rdaddr_enb=fNet.addSignal(cType,'rdAddrEnb');

    fNet.addComponent2(...
    'kind','cgireml',...
    'Name','addressGeneration',...
    'InputSignals',[cnuvalid,valid_alpha,count,reset],...
    'OutputSignals',[wraddr,rdaddr,rdvalid,wraddr_enb,rdaddr_enb],...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','addressGeneration',...
    'EMLFileBody',addressGeneration,...
    'EmlParams',{blockInfo.vaddrWL},...
    'EMLFlag_TreatInputIntsAsFixpt',true);

    shiftreg=fNet.addSignal(shiftout.Type,'shiftReg');
    pirelab.getUnitDelayComp(fNet,rdvalid,rdvalidreg,'',0);
    pirelab.getUnitDelayComp(fNet,shift,shiftreg,'',0);

    pirelab.getSimpleDualPortRamComp(fNet,[alpha,wraddr,valid_alpha,rdaddr],alphaD,'alphaDelay',blockInfo.memDepth,-1,[],'','','distributed');
    pirelab.getSimpleDualPortRamComp(fNet,[shiftreg,wraddr,valid_alpha,rdaddr],shiftout_reg,'shiftDelay',1,-1,[],'','','distributed');
    pirelab.getSimpleDualPortRamComp(fNet,[rdenb_delay,wraddr_enb,valid_alpha,rdaddr_enb],rdenb_reg,'Delay_rdEnb',blockInfo.memDepth,-1,[],'','','distributed');



    aNet=this.elabAposterioriNodeUnitNetwork(fNet,blockInfo,dataRate);
    aNet.addComment('Aposteriori Node Unit');
    pirelab.instantiateNetwork(fNet,aNet,[alphaD,beta1,rdvalidreg,reset],...
    [gamma,validout],'Aposteriori Node Unit');

    pirelab.getWireComp(fNet,cnucomp1,cdecomp1);
    pirelab.getWireComp(fNet,cnucomp2,cdecomp2);
    pirelab.getWireComp(fNet,cnucomp3,cdecomp3);
    pirelab.getWireComp(fNet,cnucomp4,cdecomp4);
    pirelab.getWireComp(fNet,cnuvalid,cvalid);
    pirelab.getWireComp(fNet,rdenb_reg,rdenbout);
    pirelab.getWireComp(fNet,shiftout_reg,shiftout);
end



