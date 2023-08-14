function sampleControlNet=elabSampleControl(~,topNet,datarate)

    inDataRate(1)=datarate;
    inDataRate(2)=datarate;
    inDataRate(3)=datarate;

    inportNames={'startIn','endIn','validIn'};
    outportNames={'startOut','endOut','validOut'};

    inTypes(1)=pir_ufixpt_t(1,0);
    inTypes(2)=pir_ufixpt_t(1,0);
    inTypes(3)=pir_ufixpt_t(1,0);

    outTypes(1)=pir_ufixpt_t(1,0);
    outTypes(2)=pir_ufixpt_t(1,0);
    outTypes(3)=pir_ufixpt_t(1,0);

    sampleControlNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','sampleControlNet',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',inDataRate,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );

    startIn=sampleControlNet.PirInputSignals(1);
    endIn=sampleControlNet.PirInputSignals(2);
    validIn=sampleControlNet.PirInputSignals(3);

    startOut=sampleControlNet.PirOutputSignals(1);
    endOut=sampleControlNet.PirOutputSignals(2);
    validOut=sampleControlNet.PirOutputSignals(3);

    desc='sampleBusCtrl - controller for valid start and end';

    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+commhdlsupport','+internal','@APPDecoder','cgireml','sampleBusController.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char');
    fclose(fid);

    inports=[startIn,endIn,validIn];
    outports=[startOut,endOut,validOut];

    sampleBusCtrl=sampleControlNet.addComponent2(...
    'kind','cgireml',...
    'Name','sampleBusController',...
    'InputSignals',inports,...
    'OutputSignals',outports,...
    'EMLFileName','sampleBusController',...
    'EMLFileBody',fcnBody,...
    'BlockComment',desc...
    );
    sampleBusCtrl.runConcurrencyMaximizer(0);

end
