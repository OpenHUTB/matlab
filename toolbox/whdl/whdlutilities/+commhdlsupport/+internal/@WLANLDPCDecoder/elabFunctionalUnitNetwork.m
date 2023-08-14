function fNet=elabFunctionalUnitNetwork(this,topNet,blockInfo,dataRate)






    ufix1Type=pir_ufixpt_t(1,0);
    ufix5Type=pir_ufixpt_t(5,0);
    ufix8Type=pir_ufixpt_t(8,0);%#ok<*NASGU> 
    bType=pir_sfixpt_t(blockInfo.betaWL,blockInfo.alphaFL);
    aType=pir_sfixpt_t(blockInfo.alphaWL,blockInfo.alphaFL);
    bc1Type=pir_ufixpt_t(blockInfo.betadecmpWL,0);
    bc2Type=pir_ufixpt_t(2*blockInfo.minWL,0);

    betaVType=pirelab.getPirVectorType(bType,blockInfo.memDepth);
    alphaVType=pirelab.getPirVectorType(aType,blockInfo.memDepth);
    bcVType1=pirelab.getPirVectorType(bc1Type,blockInfo.memDepth);
    bcVType2=pirelab.getPirVectorType(bc2Type,blockInfo.memDepth);


    fNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','FunctionalUnit',...
    'Inportnames',{'data','valid','count','betacomp1','betacomp2','decmpvalid','reset'},...
    'InportTypes',[alphaVType,ufix1Type,ufix5Type,bcVType1,bcVType2,ufix1Type,ufix1Type],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'gamma','gammavalid','cnuDecomp1','cnuDecomp2','cnuValid'},...
    'OutportTypes',[alphaVType,ufix1Type,bcVType1,bcVType2,ufix1Type]...
    );



    data=fNet.PirInputSignals(1);
    valid=fNet.PirInputSignals(2);
    count=fNet.PirInputSignals(3);
    betacomp1=fNet.PirInputSignals(4);
    betacomp2=fNet.PirInputSignals(5);
    decmpvalid=fNet.PirInputSignals(6);
    reset=fNet.PirInputSignals(7);

    gamma=fNet.PirOutputSignals(1);
    validout=fNet.PirOutputSignals(2);
    cdecomp1=fNet.PirOutputSignals(3);
    cdecomp2=fNet.PirOutputSignals(4);
    cvalid=fNet.PirOutputSignals(5);

    beta=fNet.addSignal(betaVType,'beta');
    betavalid=fNet.addSignal(ufix1Type,'betaValid');

    cnucomp1=fNet.addSignal(cdecomp1.Type,'cnuDecomp1');
    cnucomp2=fNet.addSignal(cdecomp2.Type,'cnuDecomp2');
    cnuvalid=fNet.addSignal(ufix1Type,'cnuValid');



    b1Net=this.elabBetaDecompressNetwork(fNet,blockInfo,dataRate);
    b1Net.addComment(['Beta_Decompress_Unit_',num2str(1)]);
    pirelab.instantiateNetwork(fNet,b1Net,[betacomp1,betacomp2,decmpvalid,count,reset],...
    [beta,betavalid],['Beta_Decompress_Unit_',num2str(1)]);

    alpha=fNet.addSignal(alphaVType,'alpha');
    alphaD=fNet.addSignal(alphaVType,'alphaD');
    valid_alpha=fNet.addSignal(ufix1Type,'alphaValid');



    vNet=this.elabVariableNodeUnitNetwork(fNet,blockInfo,dataRate);
    vNet.addComment('Variable Node Unit');
    pirelab.instantiateNetwork(fNet,vNet,[data,beta,valid,betavalid,reset],...
    [alpha,valid_alpha],'Variable Node Unit');

    alpha_reg=fNet.addSignal(alpha.Type,'alphaReg');
    valid_reg=fNet.addSignal(ufix1Type,'validReg');

    pirelab.getUnitDelayComp(fNet,alpha,alpha_reg,'alpha',0);
    pirelab.getUnitDelayComp(fNet,valid_alpha,valid_reg,'valid',0);


    alpha_dtc=fNet.addSignal(betaVType,'alphaDTC');
    pirelab.getDTCComp(fNet,alpha,alpha_dtc,'Floor','Saturate');



    cNet=this.elabCheckNodeUnitNetwork(fNet,blockInfo,dataRate);
    cNet.addComment('Check Node Unit');
    pirelab.instantiateNetwork(fNet,cNet,[alpha_dtc,valid_alpha,count,reset],...
    [cnucomp1,cnucomp2,cnuvalid],'Check Node Unit');

    beta1=fNet.addSignal(betaVType,'beta');
    betavalid1=fNet.addSignal(ufix1Type,'betaValid');


    b2Net=this.elabBetaDecompressNetwork(fNet,blockInfo,dataRate);
    b2Net.addComment(['Beta_Decompress_Unit_',num2str(2)]);
    pirelab.instantiateNetwork(fNet,b2Net,[cnucomp1,cnucomp2,cnuvalid,count,reset],...
    [beta1,betavalid1],['Beta_Decompress_Unit_',num2str(2)]);



    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+commhdlsupport','+internal','@WLANLDPCDecoder','cgireml','addressGeneration.m'),'r');
    addressGeneration=fread(fid,Inf,'char=>char');
    fclose(fid);

    wraddr=fNet.addSignal(ufix5Type,'wrAddr');
    rdaddr=fNet.addSignal(ufix5Type,'rdAddr');
    rdvalid=fNet.addSignal(ufix1Type,'rdValid');
    rdvalidreg=fNet.addSignal(ufix1Type,'rdValidReg');

    fNet.addComponent2(...
    'kind','cgireml',...
    'Name','addressGeneration',...
    'InputSignals',[cnuvalid,valid_alpha,count,reset],...
    'OutputSignals',[wraddr,rdaddr,rdvalid],...
    'ExternalSynchronousResetSignal','',...
    'EMLFileName','addressGeneration',...
    'EMLFileBody',addressGeneration,...
    'EMLFlag_TreatInputIntsAsFixpt',true);

    pirelab.getUnitDelayComp(fNet,rdvalid,rdvalidreg,'',0);

    pirelab.getSimpleDualPortRamComp(fNet,[alpha_reg,wraddr,valid_reg,rdaddr],alphaD,'VariableDelay',blockInfo.memDepth,-1,[],'','',blockInfo.ramAttr_dist);



    aNet=this.elabAposterioriNodeUnitNetwork(fNet,blockInfo,dataRate);
    aNet.addComment('Aposteriori Node Unit');
    pirelab.instantiateNetwork(fNet,aNet,[alphaD,beta1,rdvalidreg,reset],...
    [gamma,validout],'Aposteriori Node Unit');

    pirelab.getWireComp(fNet,cnucomp1,cdecomp1);
    pirelab.getWireComp(fNet,cnucomp2,cdecomp2);
    pirelab.getWireComp(fNet,cnuvalid,cvalid);

end

