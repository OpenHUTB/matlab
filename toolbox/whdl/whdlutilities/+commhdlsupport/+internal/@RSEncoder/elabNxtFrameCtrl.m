function nxtFrameNet=elabNxtFrameCtrl(~,topNet,datarate)

    inDataRate(1)=datarate;
    inDataRate(2)=datarate;
    inDataRate(3)=datarate;
    inDataRate(4)=datarate;

    inportNames={'startIn','endIn','counterEnb','resetIfNoEnd'};
    outportNames={'nextFrame'};

    inTypes(1)=pir_ufixpt_t(1,0);
    inTypes(2)=pir_ufixpt_t(1,0);
    inTypes(3)=pir_ufixpt_t(1,0);
    inTypes(4)=pir_ufixpt_t(1,0);

    outTypes(1)=pir_ufixpt_t(1,0);


    nxtFrameNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','nxtFrameNet',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',inDataRate,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );

    startIn=nxtFrameNet.PirInputSignals(1);
    endIn=nxtFrameNet.PirInputSignals(2);
    counterEnb=nxtFrameNet.PirInputSignals(3);
    resetIfNoEnd=nxtFrameNet.PirInputSignals(4);

    nextFrame=nxtFrameNet.PirOutputSignals(1);


    desc='nextFrameCtrl - state machine for next frame signal output';

    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+commhdlsupport','+internal','@RSEncoder','cgireml',...
    'nextFrameController.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char');
    fclose(fid);

    inports=[startIn,endIn,counterEnb,resetIfNoEnd];
    outports=nextFrame;

    nxtFrameCtrl=nxtFrameNet.addComponent2(...
    'kind','cgireml',...
    'Name','nextFrameController',...
    'InputSignals',inports,...
    'OutputSignals',outports,...
    'EMLFileName','nextFrameController',...
    'EMLFileBody',fcnBody,...
    'BlockComment',desc...
    );
    nxtFrameCtrl.runConcurrencyMaximizer(0);

end
