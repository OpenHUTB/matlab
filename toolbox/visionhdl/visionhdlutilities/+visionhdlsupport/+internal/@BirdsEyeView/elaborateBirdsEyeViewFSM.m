function BirdsEyeViewFSMNet=elaborateBirdsEyeViewFSM(this,topNet,blockInfo,sigInfo,dataRate)














    booleanT=sigInfo.booleanT;
    rowCounterType=sigInfo.readCounterType;
    FSMType=sigInfo.FSMType;



    inPortNames={'vEndIn','validIn','RowCounterIn','vStartIn'}';
    inPortRates=[dataRate,dataRate,dataRate,dataRate];
    inPortTypes=[booleanT,booleanT,rowCounterType,booleanT];
    outPortNames={'push','pop','LockedInFrame','FSMState'};
    outPortTypes=[booleanT,booleanT,booleanT,FSMType];



    BirdsEyeViewFSMNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','dataWriteFSM',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );





    compName='BirdsEyeViewFSM';
    desc='Birds-Eye View FSM - Determine whether to idle, buffer or write data';
    fid=fopen(fullfile(matlabroot,'toolbox','visionhdl','visionhdlutilities',...
    '+visionhdlsupport','+internal','@BirdsEyeView','cgireml',[compName,'.m']));
    fcnBody=fread(fid,Inf,'char=>char');

    START_LINE=blockInfo.StartLine+1;
    END_LINE=(blockInfo.EndLine)+3;


    fcnBody=(strrep(fcnBody','START_LINE',num2str(START_LINE)))';
    fcnBody=(strrep(fcnBody','END_LINE',num2str(END_LINE)))';


    fclose(fid);

    FSMInput=BirdsEyeViewFSMNet.PirInputSignals;
    FSMOutput=BirdsEyeViewFSMNet.PirOutputSignals;

    BirdsEyeViewFSM=BirdsEyeViewFSMNet.addComponent2(...
    'kind','cgireml',...
    'Name','BirdsEyeViewFSM',...
    'InputSignals',FSMInput,...
    'OutputSignals',FSMOutput,...
    'EMLFileName','BirdsEyeViewFSM',...
    'EMLFileBody',fcnBody,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'BlockComment',desc);
    BirdsEyeViewFSM.runConcurrencyMaximizer(0);


























