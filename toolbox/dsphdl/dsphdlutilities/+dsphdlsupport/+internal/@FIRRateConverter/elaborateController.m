function newNet=elaborateController(this,hN,blockInfo,phaseType)








    dataRate=hN.PirInputSignals(1).SimulinkRate;

    newNet=pirelab.createNewNetwork(...
    'Network',hN,...
    'Name','FIR Rate Converter Controller',...
    'InportNames',{'dataValid'},...
    'InportTypes',pir_boolean_t,...
    'InportRates',dataRate,...
    'OutportNames',{'phase','phaseValid','ready'},...
    'OutportTypes',[phaseType,pir_boolean_t,pir_boolean_t]);

    newNet.addComment('FIR Rate Converter Controller');





    dataValid=newNet.PirInputSignals(1);

    phase=newNet.PirOutputSignals(1);
    phaseValid=newNet.PirOutputSignals(2);
    ready=newNet.PirOutputSignals(3);





    L=blockInfo.InterpolationFactor;
    M=blockInfo.DecimationFactor;
    [phaseTableData,inCountTableData]=getSequencingData(L,M);





    rdyToAdv=newNet.addSignal(pir_boolean_t,'rdyToAdv');
    advance=newNet.addSignal(pir_boolean_t,'advance');
    outputCount=newNet.addSignal(phaseType,'outputCount');
    phaseTableOut=newNet.addSignal(phaseType,'phaseTableOut');

    inputCount_t=pir_fixpt_t(0,inCountTableData.WordLength,0);

    inputCountTableOut=newNet.addSignal(inputCount_t,'inputCountTableOut');
    inputCount=newNet.addSignal(inputCount_t,'inputCount');
    nextInputCount=newNet.addSignal(inputCount_t,'nextInputCount');






    phase.SimulinkRate=dataRate;
    phaseValid.SimulinkRate=dataRate;
    ready.SimulinkRate=dataRate;


    pirelab.getWireComp(newNet,rdyToAdv,advance);

    if L>1


        pirelab.getCounterComp(newNet,advance,outputCount,'Count limited',...
        0,1,L-1,...
        false,false,true,false,...
        'OutCounter');


        this.getSimpleLookupComp(newNet,outputCount,phaseTableOut,phaseTableData,...
        'phaseTable','polyphase index for each ouput');

        this.getSimpleLookupComp(newNet,outputCount,inputCountTableOut,inCountTableData,...
        'inCountTable','number of input samples needed for each output');

    else



        pirelab.getConstComp(newNet,phaseTableOut,0,'dummyDataOut');
        pirelab.getConstComp(newNet,inputCountTableOut,M,'dummyDataOut');

    end



    elaborateInputControl(newNet,inputCountTableOut,advance,dataValid,inputCount,ready,rdyToAdv,nextInputCount);
    pirelab.getUnitDelayComp(newNet,nextInputCount,inputCount,'inputCountReg',1);


    if L>1
        pirelab.getUnitDelayEnabledComp(newNet,phaseTableOut,phase,advance,'phaseReg');
    else
        pirelab.getConstComp(newNet,phase,0,'phaseOut');
    end

    pirelab.getUnitDelayComp(newNet,rdyToAdv,phaseValid,'phaseValidReg');


    for k=1:length(newNet.Signals)
        newNet.Signals(k).SimulinkRate=dataRate;
    end

end



function[phaseTableData,inCountTableData]=getSequencingData(L,M)


    phaseSeqUnwrapped=M*(0:L).';


    phaseSeq=mod(phaseSeqUnwrapped(1:end-1),L);
    phaseWordLength=max(1,ceil(log2(L)));
    phaseTableData=fi(phaseSeq,0,phaseWordLength,0);


    countSeq=diff(floor(phaseSeqUnwrapped/L));
    W=ceil(log2(max(countSeq)+1));
    inCountTableData=fi(countSeq,0,W,0);

end



function elaborateInputControl(hN,countToLoad,load,dataValid,count,ready,rdyToAdv,nextCount)


    compname='inputControl';
    fid=fopen(fullfile(matlabroot,...
    'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
    '@FIRRateConverter','cgireml',[compname,'.m']));
    fcnBody=fread(fid,Inf,'char=>char');
    fclose(fid);

    inputSignals=[countToLoad,load,dataValid,count];
    outputSignals=[ready,rdyToAdv,nextCount];
    desc='Input control counter combinatorial logic';

    hN.addComponent2(...
    'kind','cgireml',...
    'Name','InputControl',...
    'InputSignals',inputSignals,...
    'OutputSignals',outputSignals,...
    'EMLFileName',compname,...
    'EMLFileBody',fcnBody,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'BlockComment',desc);

end
