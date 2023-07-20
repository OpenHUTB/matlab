function padControlNet=elaboratePaddingController(~,topNet,blockInfo,sigInfo,dataRate)








    booleanT=sigInfo.booleanT;

    inPortNames={'PrePadFlag','OnLineFlag',' PostPadFlag','DumpingFlag','BlankingFlag'};
    inPortTypes=[booleanT,booleanT,booleanT,booleanT,booleanT];
    inPortRates=[dataRate,dataRate,dataRate,dataRate,dataRate];
    outPortNames={'processData','countReset','countEn','dumpControl','PrePadding'};
    outPortTypes=[booleanT,booleanT,booleanT,booleanT,booleanT];

    padControlNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','PaddingController',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );


    compName='PaddingController';


    desc='Padding Controller';

    fid=fopen(fullfile(matlabroot,'toolbox','visionhdl','visionhdlutilities',...
    '+visionhdlsupport','+internal','@LineBuffer','cgireml',[compName,'.m']));
    fcnBody=fread(fid,Inf,'char=>char');
    fclose(fid);

    FSMInput=padControlNet.PirInputSignals;
    FSMOutput=padControlNet.PirOutputSignals;

    padControl=padControlNet.addComponent2(...
    'kind','cgireml',...
    'Name','PaddingController',...
    'InputSignals',FSMInput,...
    'OutputSignals',FSMOutput,...
    'EMLFileName','PaddingController',...
    'EMLFileBody',fcnBody,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'BlockComment',desc);
    padControl.runConcurrencyMaximizer(0);
















