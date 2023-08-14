function utilImplementStateSystem_v2(hstateSystemIn1StateNew,...
    hstateSystemIn2ModeNew,hstateSystemOut1State,...
    hstateSystemOut2Mode,hstateSystem,stateSpaceParameters,numSolverIters,...
    initialState,hstateSystemOut3Enable,singleRateModel)




    stateSystem=getfullname(hstateSystem);


    set_param(hstateSystemIn1StateNew,'Position',[1145,98,1175,112]);
    set_param(hstateSystemIn2ModeNew,'Position',[430,228,460,242]);
    set_param(hstateSystemOut1State,'Position',[640,143,670,157]);
    set_param(hstateSystemOut2Mode,'Position',[640,283,670,297]);
    if~isempty(hstateSystemOut3Enable)
        set_param(hstateSystemOut3Enable,'Position',[990,468,1020,482]);
    end



    sampleTime=compactButAccurateNum2Str(stateSpaceParameters.DiscreteSampleTime/double(numSolverIters));
    if singleRateModel
        enableSampleTime=sampleTime;
    else
        enableSampleTime=compactButAccurateNum2Str(stateSpaceParameters.DiscreteSampleTime);
    end




    henableConstantBlk=add_block('hdlsllib/Sources/Constant',strcat(stateSystem,'/Valid Out'),...
    'MakeNameUnique','on',...
    'Value','1',...
    'SampleTime',enableSampleTime,...
    'OutDataTypeStr','boolean',...
    'Position',[20,275,50,305]);

    if singleRateModel
        delayLength1=int2str(numSolverIters);
    else
        delayLength1='1';
    end

    hdelayBlk1=add_block('hdlsllib/Discrete/Delay',strcat(stateSystem,'/Delay1'),...
    'MakeNameUnique','on',...
    'DelayLength',delayLength1,...
    'Position',[95,273,130,307]);
    hdelayBlk2=add_block('hdlsllib/Discrete/Delay',strcat(stateSystem,'/Delay2'),...
    'MakeNameUnique','on',...
    'DelayLength',delayLength1,...
    'Position',[205,133,240,167]);
    if~singleRateModel

        hstateSelectRateTransitionBlk=add_block('hdlsllib/Signal Attributes/Rate Transition',strcat(stateSystem,'/Rate Transition1'),...
        'MakeNameUnique','on',...
        'OutPortSampleTimeOpt','Multiple of input port sample time',...
        'OutPortSampleTimeMultiple',strcat('1/',num2str(numSolverIters)),...
        'Position',[280,129,320,171]);
        hmodeSelectRateTransitionBlk=add_block('hdlsllib/Signal Attributes/Rate Transition',strcat(stateSystem,'/Rate Transition2'),...
        'MakeNameUnique','on',...
        'OutPortSampleTimeOpt','Multiple of input port sample time',...
        'OutPortSampleTimeMultiple',strcat('1/',num2str(numSolverIters)),...
        'Position',[280,269,320,311]);
    end

    hinitialStateConstantBlk=add_block('hdlsllib/Sources/Constant',strcat(stateSystem,'/X0'),...
    'MakeNameUnique','on',...
    'Value',initialState,...
    'SampleTime',sampleTime,...
    'Position',[365,185,395,215]);

    numIndexBits=ceil(log2(stateSpaceParameters.NumberOfSwitchingModes));

    hinitialModeConstantBlk=add_block('hdlsllib/Sources/Constant',strcat(stateSystem,'/Constant'),...
    'MakeNameUnique','on',...
    'Value',strcat('fi(','0,0,',num2str(numIndexBits),',0)'),...
    'SampleTime',sampleTime,...
    'Position',[365,325,395,355]);


    hmodeSelectDelayBlk=add_block('hdlsllib/Discrete/Delay',strcat(stateSystem,'/Delay'),...
    'MakeNameUnique','on',...
    'DelayLength','1',...
    'Position',[365,273,400,307]);


    hstateSelectSwitchBlk=add_block('hdlsllib/Signal Routing/Switch',strcat(stateSystem,'/Switch'),...
    'MakeNameUnique','on',...
    'Position',[515,130,565,170],...
    'Criteria','u2 ~= 0');
    hmodeSelectSwitchBlk=add_block('hdlsllib/Signal Routing/Switch',strcat(stateSystem,'/Switch1'),...
    'MakeNameUnique','on',...
    'Position',[515,270,565,310],...
    'Criteria','u2 ~= 0');
    hswitchBlk=add_block('hdlsllib/Signal Routing/Switch',strcat(stateSystem,'/Switch3'),...
    'MakeNameUnique','on',...
    'Position',[1210,100,1260,140],...
    'Criteria','u2 ~= 0');


    hstorageDelayBlk=add_block('hdlsllib/Discrete/Delay',strcat(stateSystem,'/Delay3'),...
    'MakeNameUnique','on',...
    'DelayLength','1',...
    'Position',[1325,102,1360,138]);


    hcounterBlk=add_block('hdlsllib/Sources/Counter Limited',strcat(stateSystem,'/Counter Limited'),...
    'uplimit',num2str(numSolverIters-1),...
    'Position',[365,425,395,455]);


    hcomparatorBlk=add_block('hdlsllib/Logic and Bit Operations/Compare To Constant',strcat(stateSystem,'/Compare To Constant'),...
    'relop','==',...
    'const','0',...
    'Position',[745,425,775,455]);


    hbitwiseAnd=add_block('hdlsllib/Logic and Bit Operations/Bitwise Operator',strcat(stateSystem,'/Bitwise Operator'),...
    'logicop','AND',...
    'UseBitMask','off',...
    'NumInputPorts','2',...
    'Position',[905,411,945,449]);



    add_line(stateSystem,strcat(get_param(henableConstantBlk,'Name'),'/1'),strcat(get_param(hdelayBlk1,'Name'),'/1'),...
    'autorouting','on');

    add_line(stateSystem,strcat(get_param(hdelayBlk1,'Name'),'/1'),strcat(get_param(hdelayBlk2,'Name'),'/1'),...
    'autorouting','on');
    if singleRateModel
        add_line(stateSystem,strcat(get_param(hdelayBlk1,'Name'),'/1'),strcat(get_param(hmodeSelectDelayBlk,'Name'),'/1'),...
        'autorouting','on');

        add_line(stateSystem,strcat(get_param(hdelayBlk2,'Name'),'/1'),strcat(get_param(hstateSelectSwitchBlk,'Name'),'/2'),...
        'autorouting','on');
        if~isempty(hstateSystemOut3Enable)
            add_line(stateSystem,strcat(get_param(hbitwiseAnd,'Name'),'/1'),strcat(get_param(hstateSystemOut3Enable,'Name'),'/1'),...
            'autorouting','on');
        end
    else
        add_line(stateSystem,strcat(get_param(hdelayBlk1,'Name'),'/1'),strcat(get_param(hmodeSelectRateTransitionBlk,'Name'),'/1'),...
        'autorouting','on');

        add_line(stateSystem,strcat(get_param(hdelayBlk2,'Name'),'/1'),strcat(get_param(hstateSelectRateTransitionBlk,'Name'),'/1'),...
        'autorouting','on');

        add_line(stateSystem,strcat(get_param(hstateSelectRateTransitionBlk,'Name'),'/1'),strcat(get_param(hstateSelectSwitchBlk,'Name'),'/2'),...
        'autorouting','on');

        add_line(stateSystem,strcat(get_param(hmodeSelectRateTransitionBlk,'Name'),'/1'),strcat(get_param(hmodeSelectDelayBlk,'Name'),'/1'),...
        'autorouting','on');
    end
    add_line(stateSystem,strcat(get_param(hmodeSelectDelayBlk,'Name'),'/1'),strcat(get_param(hmodeSelectSwitchBlk,'Name'),'/2'),...
    'autorouting','on');
    add_line(stateSystem,strcat(get_param(hmodeSelectDelayBlk,'Name'),'/1'),strcat(get_param(hbitwiseAnd,'Name'),'/1'),...
    'autorouting','on');

    add_line(stateSystem,strcat(get_param(hinitialStateConstantBlk,'Name'),'/1'),strcat(get_param(hstateSelectSwitchBlk,'Name'),'/3'),...
    'autorouting','on');

    add_line(stateSystem,strcat(get_param(hinitialModeConstantBlk,'Name'),'/1'),strcat(get_param(hmodeSelectSwitchBlk,'Name'),'/3'),...
    'autorouting','on');

    add_line(stateSystem,strcat(get_param(hstateSelectSwitchBlk,'Name'),'/1'),strcat(get_param(hstateSystemOut1State,'Name'),'/1'),...
    'autorouting','on');

    add_line(stateSystem,strcat(get_param(hmodeSelectSwitchBlk,'Name'),'/1'),strcat(get_param(hstateSystemOut2Mode,'Name'),'/1'),...
    'autorouting','on');

    add_line(stateSystem,strcat(get_param(hstateSystemIn2ModeNew,'Name'),'/1'),strcat(get_param(hmodeSelectSwitchBlk,'Name'),'/1'),...
    'autorouting','on');

    add_line(stateSystem,strcat(get_param(hcounterBlk,'Name'),'/1'),strcat(get_param(hcomparatorBlk,'Name'),'/1'),...
    'autorouting','on');

    add_line(stateSystem,strcat(get_param(hcomparatorBlk,'Name'),'/1'),strcat(get_param(hbitwiseAnd,'Name'),'/2'),...
    'autorouting','on');

    add_line(stateSystem,strcat(get_param(hbitwiseAnd,'Name'),'/1'),strcat(get_param(hswitchBlk,'Name'),'/2'),...
    'autorouting','on');

    add_line(stateSystem,strcat(get_param(hstateSystemIn1StateNew,'Name'),'/1'),strcat(get_param(hswitchBlk,'Name'),'/1'),...
    'autorouting','on');

    add_line(stateSystem,strcat(get_param(hswitchBlk,'Name'),'/1'),strcat(get_param(hstorageDelayBlk,'Name'),'/1'),...
    'autorouting','on');

    add_line(stateSystem,strcat(get_param(hswitchBlk,'Name'),'/1'),strcat(get_param(hstateSelectSwitchBlk,'Name'),'/1'),...
    'autorouting','on');
    add_line(stateSystem,strcat(get_param(hstorageDelayBlk,'Name'),'/1'),strcat(get_param(hswitchBlk,'Name'),'/3'),...
    'autorouting','on');
    Simulink.BlockDiagram.arrangeSystem(stateSystem,'FullLayout','True','Animation','False');

end


