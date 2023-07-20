function octrlNet=elabOutputControl(~,topNet,blockInfo,dataRate)




    boolType=pir_boolean_t();
    addrType=blockInfo.dataRAMaddrType;

    extrinType=blockInfo.extrinType;








    inportNames={'extrinsicIn','decision','w_addr','w_enb','outputStart','bLen'};
    inTypes=[extrinType,boolType,addrType,boolType,boolType,addrType];
    indataRates=dataRate*ones(1,length(inportNames));

    outportNames={'extrinsicOut','dataOut','startOut','endOut','validOut'};
    outTypes=[extrinType,boolType,boolType,boolType,boolType];

    octrlNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','OutputControl',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',indataRates,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );



    extrinsicIn=octrlNet.PirInputSignals(1);
    decisionIn=octrlNet.PirInputSignals(2);
    w_addr=octrlNet.PirInputSignals(3);
    w_enb=octrlNet.PirInputSignals(4);
    outputStart=octrlNet.PirInputSignals(5);
    bLen=octrlNet.PirInputSignals(6);


    extrinsicOut=octrlNet.PirOutputSignals(1);
    dataOut=octrlNet.PirOutputSignals(2);
    startOut=octrlNet.PirOutputSignals(3);
    endOut=octrlNet.PirOutputSignals(4);
    validOut=octrlNet.PirOutputSignals(5);



    ramdataType=pir_ufixpt_t(extrinType.WordLength+1,0);
    concatdata=octrlNet.addSignal(ramdataType,'concatdata');
    ramdataIn=octrlNet.addSignal(ramdataType,'dataIn');


    pirelab.getBitConcatComp(octrlNet,[extrinsicIn,decisionIn],concatdata);
    pirelab.getUnitDelayComp(octrlNet,concatdata,ramdataIn);


    ram_w_addr=octrlNet.addSignal(addrType,'ram_w_addr');
    allpdelay=80;
    pirelab.getIntDelayComp(octrlNet,w_addr,ram_w_addr,allpdelay);



    addrO=octrlNet.addSignal(addrType,'addrO');
    startO=octrlNet.addSignal(boolType,'startO');
    endO=octrlNet.addSignal(boolType,'endO');
    validO=octrlNet.addSignal(boolType,'validO');

    addrO_delay=octrlNet.addSignal(addrType,'addrO_delay');
    ram_r_addr=octrlNet.addSignal(addrType,'ram_r_addr');
    validO_delay1=octrlNet.addSignal(boolType,'validO_delay1');
    validO_delay2=octrlNet.addSignal(boolType,'validO_delay2');

    desc='Output Controller';

    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+ltehdlsupport','+internal','@TurboDecoder','cgireml','outputController.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char');

    fclose(fid);


    inports=[outputStart,bLen];

    outports=[addrO,startO,endO,validO];

    outcontroller=octrlNet.addComponent2(...
    'kind','cgireml',...
    'Name','outputController',...
    'InputSignals',inports,...
    'OutputSignals',outports,...
    'EMLFileName','outputController',...
    'EMLFileBody',fcnBody,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'BlockComment',desc);
    outcontroller.runConcurrencyMaximizer(0);

    pirelab.getIntDelayComp(octrlNet,addrO,addrO_delay,2);
    pirelab.getIntDelayComp(octrlNet,validO,validO_delay1,2);

    pirelab.getSwitchComp(octrlNet,[addrO_delay,w_addr],ram_r_addr,validO_delay1,'','==',1);




    ram_w_enb=octrlNet.addSignal(boolType,'ram_w_enb');
    ramout=octrlNet.addSignal(ramdataType,'ramOut');
    ramout_delay=octrlNet.addSignal(ramdataType,'ramOut_delay');

    dcdelay=2+4+2+5+1;
    pirelab.getIntDelayComp(octrlNet,w_enb,ram_w_enb,dcdelay);

    pirelab.getSimpleDualPortRamComp(octrlNet,[ramdataIn,ram_w_addr,ram_w_enb,ram_r_addr],ramout,'ExtrinsicRAM');
    pirelab.getUnitDelayComp(octrlNet,ramout,ramout_delay);


    extrinufixType=pir_ufixpt_t(extrinType.WordLength,0);
    decisionufixType=pir_ufixpt_t(1,0);
    extrin_unsign=octrlNet.addSignal(extrinufixType,'extrin_unsign');
    decision_unsign=octrlNet.addSignal(decisionufixType,'decision_unsign');
    decision=octrlNet.addSignal(boolType,'decision');

    comp=pirelab.getBitSliceComp(octrlNet,ramout_delay,decision_unsign,0,0);
    comp.addComment('split extrinsic and decision');
    pirelab.getBitSliceComp(octrlNet,ramout_delay,extrin_unsign,extrinType.WordLength,1);

    pirelab.getDTCComp(octrlNet,extrin_unsign,extrinsicOut,'Floor','Wrap','SI');
    pirelab.getDTCComp(octrlNet,decision_unsign,decision,'Floor','Wrap','SI');

    eramdelay=2;
    pirelab.getIntDelayComp(octrlNet,validO_delay1,validO_delay2,eramdelay);

    constfalse=octrlNet.addSignal(boolType,'constFalse');
    pirelab.getConstComp(octrlNet,constfalse,false);


    pirelab.getSwitchComp(octrlNet,[decision,constfalse],dataOut,validO_delay2,'','==',1);

    pirelab.getIntDelayComp(octrlNet,startO,startOut,2+eramdelay);
    pirelab.getIntDelayComp(octrlNet,endO,endOut,2+eramdelay);
    pirelab.getDTCComp(octrlNet,validO_delay2,validOut);



