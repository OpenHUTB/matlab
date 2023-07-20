function sampleModCodeRateIdxNet=elabLoadModIdxCodeRateIdx(~,topNet,~,datarate)



    inDataRateModCod(1)=datarate;
    inDataRateModCod(2)=datarate;
    inDataRateModCod(3)=datarate;
    inDataRateModCod(4)=datarate;

    inportNamesModCod={'startSample','modIdx','codeRateIdx','validIn'};
    outportNamesModCod={'modIdxSampled','codeRateIdxSampled','resetIn','bpskEvenSymFlag'};

    inTypesModCod(1)=pir_ufixpt_t(1,0);
    inTypesModCod(2)=pir_ufixpt_t(3,0);
    inTypesModCod(3)=pir_ufixpt_t(4,0);
    inTypesModCod(4)=pir_ufixpt_t(1,0);

    outTypesModCod(1)=pir_ufixpt_t(3,0);
    outTypesModCod(2)=pir_ufixpt_t(3,0);
    outTypesModCod(3)=pir_ufixpt_t(1,0);
    outTypesModCod(4)=pir_ufixpt_t(1,0);

    sampleModCodeRateIdxNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','sampleModCodeRateIdxNet',...
    'InportNames',inportNamesModCod,...
    'InportTypes',inTypesModCod,...
    'InportRates',inDataRateModCod,...
    'OutportNames',outportNamesModCod,...
    'OutportTypes',outTypesModCod...
    );

    startSample=sampleModCodeRateIdxNet.PirInputSignals(1);
    modIdx=sampleModCodeRateIdxNet.PirInputSignals(2);
    codeRateIdx=sampleModCodeRateIdxNet.PirInputSignals(3);
    validIn=sampleModCodeRateIdxNet.PirInputSignals(4);
    modIdxSampled=sampleModCodeRateIdxNet.PirOutputSignals(1);
    codeRateIdxSampled=sampleModCodeRateIdxNet.PirOutputSignals(2);
    resetIn=sampleModCodeRateIdxNet.PirOutputSignals(3);
    bpskEvenSymFlag=sampleModCodeRateIdxNet.PirOutputSignals(4);

    desc='sample modulation index and code rate';

    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+satcomhdlsupport','+internal','@DVBS2SymbolModulator','cgireml',...
    'loadModCod.m'),'r');


    fcnBody=fread(fid,Inf,'char=>char');
    fclose(fid);

    inports=[startSample,modIdx,codeRateIdx,validIn];
    outports=[modIdxSampled,codeRateIdxSampled,resetIn,bpskEvenSymFlag];

    sampleModCodRate=sampleModCodeRateIdxNet.addComponent2(...
    'kind','cgireml',...
    'Name','loadModCod',...
    'InputSignals',inports,...
    'OutputSignals',outports,...
    'EMLFileName','loadModCod',...
    'EMLFileBody',fcnBody,...
    'BlockComment',desc...
    );
    sampleModCodRate.runConcurrencyMaximizer(0);

end
