function dramNet=elabDataRAM(~,topNet,blockInfo,dataRate)




    boolType=pir_boolean_t();
    addrType=blockInfo.dataRAMaddrType;

    dataVType=blockInfo.dataVType;
    dataType=blockInfo.dataType;




    inportNames={'dataIn','dataSource','w_addr','w_en','radd_sys','raddr_PRC','bLen'};
    inTypes=[dataVType,boolType,addrType,boolType,addrType,addrType,addrType];
    indataRates=[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate];
    outportNames={'llr_sys','llr_PRCA','llr_PRCB'};

    outTypes=[dataType,dataType,dataType];

    dramNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','DataRAM',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );


    dataIn=dramNet.PirInputSignals(1);
    dataSource=dramNet.PirInputSignals(2);
    w_addr=dramNet.PirInputSignals(3);
    w_en=dramNet.PirInputSignals(4);
    raddr_sys=dramNet.PirInputSignals(5);
    raddr_PRC=dramNet.PirInputSignals(6);
    bLen=dramNet.PirInputSignals(7);

    llr_sys=dramNet.PirOutputSignals(1);
    llr_PRCA=dramNet.PirOutputSignals(2);
    llr_PRCB=dramNet.PirOutputSignals(3);

    wdata=dramNet.addSignal(dataVType,'wdata');


    desc='Format Tail bits';

    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+ltehdlsupport','+internal','@TurboDecoder','cgireml','formatdata.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char');

    fclose(fid);

    inports=[dataIn,w_addr,bLen];

    outports=wdata;


    formatdata1=dramNet.addComponent2(...
    'kind','cgireml',...
    'Name','formatdata',...
    'InputSignals',inports,...
    'OutputSignals',outports,...
    'EMLFileName','formatdata',...
    'EMLFileBody',fcnBody,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'BlockComment',desc);
    formatdata1.runConcurrencyMaximizer(0);

    dataInsplit=wdata.split;

    negllr=dramNet.addSignal(dataType,'negllr');
    comp=pirelab.getConstComp(dramNet,negllr,blockInfo.negLLR);
    comp.addComment(' Define initial LLR');


    sysdata=dramNet.addSignal(dataType,'sysdata');
    prcAdata=dramNet.addSignal(dataType,'prcAdata');
    prcBdata=dramNet.addSignal(dataType,'prcBdata');



    debugSel=dramNet.addSignal(pir_ufixpt_t(1,0),'dataSel');
    pirelab.getDTCComp(dramNet,dataSource,debugSel);
    comp=pirelab.getSwitchComp(dramNet,[dataInsplit.PirOutputSignals(1),negllr],sysdata,debugSel,'','~=',0);
    comp.addComment('Select input data');
    pirelab.getSwitchComp(dramNet,[dataInsplit.PirOutputSignals(2),negllr],prcAdata,debugSel,'','~=',0);
    pirelab.getSwitchComp(dramNet,[dataInsplit.PirOutputSignals(3),negllr],prcBdata,debugSel,'','~=',0);



    sysRamOut=dramNet.addSignal(dataType,'sysRamOut');
    prcARamOut=dramNet.addSignal(dataType,'prcRamOut');
    prcBRamOut=dramNet.addSignal(dataType,'prcRamOut');

    pirelab.getSimpleDualPortRamComp(dramNet,[sysdata,w_addr,w_en,raddr_sys],sysRamOut,'SYSbitMemory');
    pirelab.getSimpleDualPortRamComp(dramNet,[prcAdata,w_addr,w_en,raddr_PRC],prcARamOut,'PRCAMemory');
    pirelab.getSimpleDualPortRamComp(dramNet,[prcBdata,w_addr,w_en,raddr_PRC],prcBRamOut,'PRCBMemory');




    comp=pirelab.getUnitDelayComp(dramNet,sysRamOut,llr_sys);
    comp.addComment('RAM output registers');
    pirelab.getUnitDelayComp(dramNet,prcARamOut,llr_PRCA);
    pirelab.getUnitDelayComp(dramNet,prcBRamOut,llr_PRCB);







