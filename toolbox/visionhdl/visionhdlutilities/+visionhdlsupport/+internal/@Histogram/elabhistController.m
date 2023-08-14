function mwNet=elabhistController(~,topNet,blockInfo,dataRate)





    binNumber=blockInfo.binNumber;
    binWL=blockInfo.binWL;
    binType=pir_ufixpt_t(binWL,0);

    ctlType=pir_boolean_t();


    cgiremldir=fullfile(matlabroot,'toolbox','visionhdl','visionhdlutilities',...
    '+visionhdlsupport','+internal','@Histogram','cgireml');

    inportnames={'hstartIn','hendIn','vstartIn','vendIn','validIn','binReset'};


    mwNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','HistController',...
    'InportNames',inportnames,...
    'InportTypes',[ctlType,ctlType,ctlType,ctlType,ctlType,ctlType],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'OutportNames',{'resetRAM','cmptHist','readOut','waddr'},...
    'OutportTypes',[ctlType,ctlType,ctlType,binType]...
    );


    hstartIn=mwNet.PirInputSignals(1);
    hendIn=mwNet.PirInputSignals(2);
    vstartIn=mwNet.PirInputSignals(3);
    vendIn=mwNet.PirInputSignals(4);
    validIn=mwNet.PirInputSignals(5);
    binReset=mwNet.PirInputSignals(6);

    resetRAM=mwNet.PirOutputSignals(1);
    cmptHist=mwNet.PirOutputSignals(2);
    readOut=mwNet.PirOutputSignal(3);
    waddr=mwNet.PirOutputSignals(4);

    resetDone=mwNet.addSignal(ctlType,'resetDone');
    dataAcq=mwNet.addSignal(ctlType,'dataAcq');
    rstcnt=mwNet.addSignal(binType,'rstcnt');

    vstartInReg=mwNet.addSignal(ctlType,'vStartInReg');
    pirelab.getUnitDelayComp(mwNet,vstartIn,vstartInReg);

    compName='histFSM';
    fid=fopen(fullfile(cgiremldir,'histFSM.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='FSM that generates Histogram control signals';

    fsmC=mwNet.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',[vstartInReg,vstartIn,vendIn,binReset,resetDone],...
    'OutputSignals',[resetRAM,dataAcq,readOut],...
    'EMLFileName','histFSM',...
    'EMLFileBody',fcnBody,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'BlockComment',desc);

    fsmC.runConcurrencyMaximizer(0);

    compName='memWRFSM';
    fid2=fopen(fullfile(cgiremldir,'memWRFSM.m'),'r');
    fcnBody=fread(fid2,Inf,'char=>char')';
    fclose(fid2);

    desc='FSM that generates Histogram memory w/R signals';

    fsmC=mwNet.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',[dataAcq,hstartIn,hendIn,vstartInReg,vendIn,validIn],...
    'OutputSignals',[cmptHist],...
    'EMLFileName','memWRFSM',...
    'EMLFileBody',fcnBody,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'BlockComment',desc);

    fsmC.runConcurrencyMaximizer(0);

    rstcntComp=pirelab.getCounterComp(mwNet,[dataAcq,resetRAM],rstcnt,...
    'Count limited',0,1,binNumber-1,1,0,1,0);
    rstcntComp.addComment('Memory reset address counter');
    pirelab.getCompareToValueComp(mwNet,rstcnt,resetDone,'==',binNumber-1);

    pirelab.getDTCComp(mwNet,rstcnt,waddr,'floor','Wrap');




