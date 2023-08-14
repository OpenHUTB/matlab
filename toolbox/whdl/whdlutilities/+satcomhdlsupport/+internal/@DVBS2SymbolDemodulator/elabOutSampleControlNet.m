function outSampleControlNet=elabOutSampleControlNet(~,topNet,blockInfo,datarate)




    inDataRate(1)=datarate;
    inDataRate(2)=datarate;
    inDataRate(3)=datarate;
    inDataRate(4)=datarate;


    inportNames={'endIn','validIn','resetIn','NonMul8Flag'};
    outportNames={'startOut','endOut'};

    inTypes(1)=pir_ufixpt_t(1,0);
    inTypes(2)=pir_ufixpt_t(1,0);
    inTypes(3)=pir_ufixpt_t(1,0);
    inTypes(4)=pir_ufixpt_t(1,0);

    outTypes(1)=pir_ufixpt_t(1,0);
    outTypes(2)=pir_ufixpt_t(1,0);


    outSampleControlNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','outSampleControlNet',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',inDataRate,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );

    endIn=outSampleControlNet.PirInputSignals(1);
    validIn=outSampleControlNet.PirInputSignals(2);
    resetIn=outSampleControlNet.PirInputSignals(3);
    NonMul8Flag=outSampleControlNet.PirInputSignals(4);

    startOut=outSampleControlNet.PirOutputSignals(1);
    endOut=outSampleControlNet.PirOutputSignals(2);


    desc='outsampleBusCtrl - controller for output start and end';

    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+satcomhdlsupport','+internal','@DVBS2SymbolDemodulator','cgireml',...
    'outSampleBusController.m'),'r');

    fcnBody=fread(fid,Inf,'char=>char');
    fclose(fid);

    inports=[endIn,validIn,resetIn,NonMul8Flag];
    outports=[startOut,endOut];

    sampleBusCtrl=outSampleControlNet.addComponent2(...
    'kind','cgireml',...
    'Name','outSampleBusController',...
    'InputSignals',inports,...
    'OutputSignals',outports,...
    'EMLFileName','outSampleBusController',...
    'EMLFileBody',fcnBody,...
    'BlockComment',desc...
    );
    sampleBusCtrl.runConcurrencyMaximizer(0);

end
