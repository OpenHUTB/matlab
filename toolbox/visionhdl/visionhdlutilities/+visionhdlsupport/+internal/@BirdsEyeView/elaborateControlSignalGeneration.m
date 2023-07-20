function controlGenNet=elaborateControlSignalGeneration(this,topNet,blockInfo,sigInfo,dataRate)













    inType=sigInfo.inType;
    booleanT=sigInfo.booleanT;
    readCounterType=sigInfo.readCounterType;
    FSMType=sigInfo.FSMType;



    inPortNames={'FSMState','BlankingInterval','ColumnCountIn'};
    inPortRates=[dataRate,dataRate,dataRate];
    inPortTypes=[FSMType,readCounterType,readCounterType];
    outPortNames={'hStartOut','hEndOut','vStartOut','vEndOut',...
    'validOut','EnableReadCompute','EnableBetweenLines','ColumnCountEnable','ColumnCountReset'};
    outPortTypes=[booleanT,booleanT,booleanT,booleanT,booleanT,booleanT,booleanT,booleanT,booleanT];

    controlGenNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','ControlSignalGeneration',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );



    compName='ControlSignalGeneration';
    desc='ControlSignalGeneration - Generate Output Control Signals';
    fid=fopen(fullfile(matlabroot,'toolbox','visionhdl','visionhdlutilities',...
    '+visionhdlsupport','+internal','@BirdsEyeView','cgireml',[compName,'.m']));
    fcnBody=fread(fid,Inf,'char=>char');

    BIRDSEYE_ACTIVEPIXELS=blockInfo.BirdsEyeActivePixels+1;
    fcnBody=(strrep(fcnBody','BIRDSEYE_ACTIVEPIXELS',num2str(BIRDSEYE_ACTIVEPIXELS)))';

    BIRDSEYE_ACTIVELINES=blockInfo.BirdsEyeActiveLines;
    fcnBody=(strrep(fcnBody','BIRDSEYE_ACTIVELINES',num2str(BIRDSEYE_ACTIVELINES)))';

    fclose(fid);

    FSMInput=controlGenNet.PirInputSignals;
    FSMOutput=controlGenNet.PirOutputSignals;

    controlGenerator=controlGenNet.addComponent2(...
    'kind','cgireml',...
    'Name','ControlSignalGeneration',...
    'InputSignals',FSMInput,...
    'OutputSignals',FSMOutput,...
    'EMLFileName','ControlSignalGeneration',...
    'EMLFileBody',fcnBody,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'BlockComment',desc);
    controlGenerator.runConcurrencyMaximizer(0);


