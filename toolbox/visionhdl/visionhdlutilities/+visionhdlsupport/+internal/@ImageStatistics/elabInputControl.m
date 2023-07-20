function inputControlNet=elabInputControl(~,topNet,~,~,dataRate)











    booleanT=pir_boolean_t();

    inPortNames={'hStart','hEnd','vStart','vEnd','dataValid'};

    inPortRates=[dataRate,dataRate,dataRate,dataRate,dataRate];

    inPortTypes=[booleanT,booleanT,booleanT,booleanT,booleanT];

    outPortNames={'processPixel','lineReset','frameStart'};

    outPortTypes=[booleanT,booleanT,booleanT];

    inputControlNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','dataReadFSM',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    compName='inputController';
    desc='Input Controller - respond to input control signals';

    cgiremldir=fullfile(matlabroot,'toolbox','visionhdl','visionhdlutilities',...
    '+visionhdlsupport','+internal','@ImageStatistics','cgireml');
    fid=fopen(fullfile(cgiremldir,[compName,'.m']));
    fcnBody=fread(fid,Inf,'char=>char');
    fclose(fid);

    FSMInput=inputControlNet.PirInputSignals;
    FSMOutput=inputControlNet.PirOutputSignals;

    inputControl=inputControlNet.addComponent2(...
    'kind','cgireml',...
    'Name','statsFSM',...
    'InputSignals',FSMInput,...
    'OutputSignals',FSMOutput,...
    'EMLFileName','inputController',...
    'EMLFileBody',fcnBody,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'BlockComment',desc);
    inputControl.runConcurrencyMaximizer(0);




end

