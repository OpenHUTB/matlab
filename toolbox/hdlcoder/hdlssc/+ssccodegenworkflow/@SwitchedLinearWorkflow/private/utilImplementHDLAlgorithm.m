function utilImplementHDLAlgorithm(hhdlAlgorithmSystem,hhdlAlgorithmSystemIn,hhdlAlgorithmSystemOut,...
    stateSpaceParametersVarName,stateSpaceParameters,numsolverIters,hdlAlgorithmDataType,sschdlProductSumCustomLatency)




    hdlAlgorithmSystem=getfullname(hhdlAlgorithmSystem);
    partitionFlag=strcmpi(stateSpaceParameters.Solver,'NE_PARTITIONING_ADVANCER');


    if strcmpi(hdlAlgorithmDataType,'MixedDoubleSingle')
        mixedDataType='double';
    else
        mixedDataType=hdlAlgorithmDataType;
    end


    if isempty(stateSpaceParameters.X0)
        initialState=strcat(mixedDataType,'(','0',')');
    else
        initialState=strcat(mixedDataType,'(',stateSpaceParametersVarName,'.X0',')');
    end




    if isempty(hhdlAlgorithmSystemIn)



        hhdlAlgorithmSystemIn=add_block('hdlsllib/Sources/Constant',strcat(hdlAlgorithmSystem,'/In1'),...
        'MakeNameUnique','on',...
        'Value',strcat(mixedDataType,'(','0',')'),...
        'SampleTime',compactButAccurateNum2Str(stateSpaceParameters.DiscreteSampleTime),...
        'Position',[1510,1373,1540,1387]);
    else

        set_param(hhdlAlgorithmSystemIn,'Position',[1510,1373,1540,1387]);
    end


    if isempty(hhdlAlgorithmSystemOut)



        hhdlAlgorithmSystemOut=add_block('hdlsllib/Sinks/Terminator',strcat(hdlAlgorithmSystem,'/Out1'),...
        'MakeNameUnique','on',...
        'Position',[2595,1393,2625,1407]);
    else

        set_param(hhdlAlgorithmSystemOut,'Position',[2595,1393,2625,1407]);
    end



    if numsolverIters>1

        hinputRateTransitionBlk=add_block('hdlsllib/Signal Attributes/Rate Transition',strcat(hdlAlgorithmSystem,'/Rate Transition'),...
        'MakeNameUnique','on',...
        'OutPortSampleTimeOpt','Multiple of input port sample time',...
        'OutPortSampleTimeMultiple',strcat('1/',num2str(numsolverIters)),...
        'Position',[1625,1359,1665,1401]);

        hstateRateTransitionBlk=add_block('hdlsllib/Signal Attributes/Rate Transition',strcat(hdlAlgorithmSystem,'/Rate Transition1'),...
        'MakeNameUnique','on',...
        'OutPortSampleTimeOpt','Multiple of input port sample time',...
        'OutPortSampleTimeMultiple',num2str(numsolverIters),...
        'Position',[2190,1379,2230,1421]);
        if~partitionFlag

            hmodeRateTransitionBlk=add_block('hdlsllib/Signal Attributes/Rate Transition',strcat(hdlAlgorithmSystem,'/Rate Transition2'),...
            'MakeNameUnique','on',...
            'OutPortSampleTimeOpt','Multiple of input port sample time',...
            'OutPortSampleTimeMultiple',num2str(numsolverIters),...
            'Position',[2355,1414,2395,1456]);

            hmodeDelayBlk=add_block('hdlsllib/Discrete/Delay',strcat(hdlAlgorithmSystem,'/Delay'),...
            'MakeNameUnique','on',...
            'DelayLength','1',...
            'Position',[2260,1418,2295,1452]);
        end

        hmodeSelectionSystem=utilAddSubsystem(hdlAlgorithmSystem,'Mode Selection',[1965,1230,2025,1290],'white');
        modeSelectionSystem=getfullname(hmodeSelectionSystem);

        hmodeSelectionSystemIn1=add_block('hdlsllib/Sources/In1',strcat(modeSelectionSystem,'/In1'),...
        'MakeNameUnique','on');
        hmodeSelectionSystemIn2State=add_block('hdlsllib/Sources/In1',strcat(modeSelectionSystem,'/In2'),...
        'MakeNameUnique','on');

        hmodeSelectionSystemOut1Mode=add_block('hdlsllib/Sinks/Out1',strcat(modeSelectionSystem,'/Out1'),...
        'MakeNameUnique','on');



        if partitionFlag
            utilImplementPartitionModeSelectionSystem(hmodeSelectionSystemIn1,hmodeSelectionSystemIn2State,...
            hmodeSelectionSystemOut1Mode,modeSelectionSystem,stateSpaceParametersVarName,stateSpaceParameters,numsolverIters,0);

        else
            utilImplementModeSelectionSystem(hmodeSelectionSystemIn1,hmodeSelectionSystemIn2State,...
            hmodeSelectionSystemOut1Mode,modeSelectionSystem,stateSpaceParametersVarName,stateSpaceParameters,numsolverIters);
        end

        hstateSystem=utilAddSubsystem(hdlAlgorithmSystem,'State',[1950,1362,2035,1438],'white');
        stateSystem=getfullname(hstateSystem);

        hstateSystemIn1StateNew=add_block('hdlsllib/Sources/In1',strcat(stateSystem,'/In1'),...
        'MakeNameUnique','on');
        hstateSystemIn2State=add_block('hdlsllib/Sources/In1',strcat(stateSystem,'/In2'),...
        'MakeNameUnique','on');
        hstateSystemIn3ModeNew=add_block('hdlsllib/Sources/In1',strcat(stateSystem,'/In3'),...
        'MakeNameUnique','on');

        hstateSystemOut1StateNew=add_block('hdlsllib/Sinks/Out1',strcat(stateSystem,'/Out1'),...
        'MakeNameUnique','on');
        hstateSystemOut2State=add_block('hdlsllib/Sinks/Out1',strcat(stateSystem,'/Out2'),...
        'MakeNameUnique','on');
        hstateSystemOut3Mode=add_block('hdlsllib/Sinks/Out1',strcat(stateSystem,'/Out3'),...
        'MakeNameUnique','on');

        utilImplementStateSystem(hstateSystemIn1StateNew,hstateSystemIn2State,...
        hstateSystemIn3ModeNew,hstateSystemOut1StateNew,hstateSystemOut2State,...
        hstateSystemOut3Mode,hstateSystem,stateSpaceParameters,numsolverIters,...
        initialState,mixedDataType);


        hmatchingDelayBlk=add_block('hdlsllib/Discrete/Delay',strcat(hdlAlgorithmSystem,'/Delay1'),...
        'MakeNameUnique','on',...
        'DelayLength','2',...
        'Position',[1980,1168,2015,1202]);
    end


    hstateUpdateSystem=utilAddSubsystem(hdlAlgorithmSystem,'State Update',[1810,1370,1870,1430],'white');
    stateUpdateSystem=getfullname(hstateUpdateSystem);

    hstateUpdateSystemIn1=add_block('hdlsllib/Sources/In1',strcat(stateUpdateSystem,'/In1'),...
    'MakeNameUnique','on');
    hstateUpdateSystemIn2State=add_block('hdlsllib/Sources/In1',strcat(stateUpdateSystem,'/State'),...
    'MakeNameUnique','on');
    hstateUpdateSystemIn3Sel=add_block('hdlsllib/Sources/In1',strcat(stateUpdateSystem,'/Sel'),...
    'MakeNameUnique','on');

    hstateUpdateSystemOut1=add_block('hdlsllib/Sinks/Out1',strcat(stateUpdateSystem,'/Out1'),...
    'MakeNameUnique','on');

    stateUpdateSystemParameters=struct;
    stateUpdateSystemParameters.AlgorithmDataType=hdlAlgorithmDataType;
    stateUpdateSystemParameters.SampleTime=strcat(compactButAccurateNum2Str(stateSpaceParameters.DiscreteSampleTime),'/',num2str(numsolverIters));

    if(partitionFlag)
        hstateUpdateSystemInOld2=[];
        if stateSpaceParameters.SolverMethod(1)==0


            hstateUpdateSystemInOld2=add_block('hdlsllib/Sources/In1',strcat(stateUpdateSystem,'/InOld2'),...
            'MakeNameUnique','on');
            hinputDelayRateTransitionBlk=add_block('hdlsllib/Signal Attributes/Rate Transition',strcat(hdlAlgorithmSystem,'/Rate Transition'),...
            'MakeNameUnique','on',...
            'OutPortSampleTimeOpt','Multiple of input port sample time',...
            'OutPortSampleTimeMultiple',strcat('1/',num2str(numsolverIters)),...
            'Position',[1670,1474,1710,1516]);

            hinputDelayBlock=add_block('hdlsllib/Discrete/Delay',strcat(hdlAlgorithmSystem,'/Delay'),...
            'MakeNameUnique','on',...
            'DelayLength','1',...
            'Position',[1615,1478,1650,1512]);
            add_line(hdlAlgorithmSystem,strcat(get_param(hinputDelayBlock,'Name'),'/1'),strcat(get_param(hinputDelayRateTransitionBlk,'Name'),'/1'),...
            'autorouting','on');
            add_line(hdlAlgorithmSystem,strcat(get_param(hhdlAlgorithmSystemIn,'Name'),'/1'),strcat(get_param(hinputDelayBlock,'Name'),'/1'),...
            'autorouting','on');
            add_line(hdlAlgorithmSystem,strcat(get_param(hinputDelayRateTransitionBlk,'Name'),'/1'),strcat(get_param(hstateUpdateSystem,'Name'),'/4'),...
            'autorouting','on');




        end
        stateUpdateSystemParameters.StateParameter=cell(2,size(stateSpaceParameters.Ad,2));
        stateUpdateSystemParameters.InputParameter=cell(2,size(stateSpaceParameters.Ad,2));
        stateUpdateSystemParameters.BiasParameter=cell(2,size(stateSpaceParameters.Ad,2));
        stateUpdateSystemParameters.SolverMethod=stateSpaceParameters.SolverMethod(1:size(stateSpaceParameters.Ad,2));

        for numPartition=1:size(stateSpaceParameters.Ad,2)
            stateUpdateSystemParameters.StateParameter{1,numPartition}=strcat(stateSpaceParametersVarName,'.Ad{',num2str(numPartition),'}');
            stateUpdateSystemParameters.InputParameter{1,numPartition}=strcat(stateSpaceParametersVarName,'.Bd{',num2str(numPartition),'}');
            stateUpdateSystemParameters.BiasParameter{1,numPartition}=strcat(stateSpaceParametersVarName,'.F0d{',num2str(numPartition),'}');
            stateUpdateSystemParameters.StateParameter{2,numPartition}=(stateSpaceParameters.Ad{numPartition});
            stateUpdateSystemParameters.InputParameter{2,numPartition}=(stateSpaceParameters.Bd{numPartition});
            stateUpdateSystemParameters.BiasParameter{2,numPartition}=(stateSpaceParameters.F0d{numPartition});
            stateUpdateSystemParameters.nonlinearity=stateSpaceParameters.nonlinearity;

        end
        utilImplementPartitionEquationSystem(hstateUpdateSystemIn1,...
        hstateUpdateSystemIn2State,hstateUpdateSystemIn3Sel,...
        hstateUpdateSystemOut1,stateUpdateSystem,stateUpdateSystemParameters,hstateUpdateSystemInOld2);
    else


        stateUpdateSystemParameters.StateParameter={strcat(stateSpaceParametersVarName,'.Ad'),(stateSpaceParameters.Ad)};
        stateUpdateSystemParameters.InputParameter={strcat(stateSpaceParametersVarName,'.Bd'),(stateSpaceParameters.Bd)};
        stateUpdateSystemParameters.BiasParameter={strcat(stateSpaceParametersVarName,'.F0d'),(stateSpaceParameters.F0d)};

        if strcmpi(hdlfeature('SSCHDLNonLinear'),'on')
            stateUpdateSystemParameters.Mass={strcat(stateSpaceParametersVarName,'.Md'),(stateSpaceParameters.Md)};
            stateUpdateSystemParameters.Nonlinearity={strcat(stateSpaceParametersVarName,'.nonlinearity'),(stateSpaceParameters.nonlinearity)};
            stateUpdateSystemParameters.NonlinearityJ={strcat(stateSpaceParametersVarName,'.nonlinearity'),(stateSpaceParameters.nonlinearityJ)};

            utilImplementBackwardEulerNonLinearEquationSystem(hstateUpdateSystemIn1,...
            hstateUpdateSystemIn2State,hstateUpdateSystemIn3Sel,...
            hstateUpdateSystemOut1,stateUpdateSystem,stateUpdateSystemParameters);
        else
            utilImplementEquationSystem(hstateUpdateSystemIn1,...
            hstateUpdateSystemIn2State,hstateUpdateSystemIn3Sel,...
            hstateUpdateSystemOut1,stateUpdateSystem,stateUpdateSystemParameters);
        end
    end

    hstateDelayBlk=add_block('hdlsllib/Discrete/Delay',strcat(hdlAlgorithmSystem,'/State Delay'),...
    'MakeNameUnique','on',...
    'DelayLength','1',...
    'InitialCondition',initialState,...
    'Position',[2105,1359,2135,1391]);


    houtputSystem=utilAddSubsystem(hdlAlgorithmSystem,'Output',[2480,1370,2540,1430],'white');
    outputSystem=getfullname(houtputSystem);

    houtputSystemIn1=add_block('hdlsllib/Sources/In1',strcat(outputSystem,'/In1'),...
    'MakeNameUnique','on');
    houtputSystemIn2State=add_block('hdlsllib/Sources/In1',strcat(outputSystem,'/State'),...
    'MakeNameUnique','on');
    houtputSystemIn3Sel=add_block('hdlsllib/Sources/In1',strcat(outputSystem,'/Sel'),...
    'MakeNameUnique','on');

    houtputSystemOut1=add_block('hdlsllib/Sinks/Out1',strcat(outputSystem,'/Out1'),...
    'MakeNameUnique','on');

    outputSystemParameters=struct;
    if(partitionFlag)
        outputSystemParameters.StateParameter=cell(2,size(stateSpaceParameters.Cd,2));
        outputSystemParameters.InputParameter=cell(2,size(stateSpaceParameters.Cd,2));
        outputSystemParameters.BiasParameter=cell(2,size(stateSpaceParameters.Cd,2));
        outputSystemParameters.AlgorithmDataType=hdlAlgorithmDataType;
        outputSystemParameters.SolverMethod=stateSpaceParameters.SolverMethod(size(stateSpaceParameters.Ad,2)+1:end);
        for numPartition=1:size(stateSpaceParameters.Cd,2)
            outputSystemParameters.StateParameter{1,numPartition}=strcat(stateSpaceParametersVarName,'.Cd{',num2str(numPartition),'}');
            outputSystemParameters.InputParameter{1,numPartition}=strcat(stateSpaceParametersVarName,'.Dd{',num2str(numPartition),'}');
            outputSystemParameters.BiasParameter{1,numPartition}=strcat(stateSpaceParametersVarName,'.Y0d{',num2str(numPartition),'}');
            outputSystemParameters.StateParameter{2,numPartition}=(stateSpaceParameters.Cd{numPartition});
            outputSystemParameters.InputParameter{2,numPartition}=(stateSpaceParameters.Dd{numPartition});
            outputSystemParameters.BiasParameter{2,numPartition}=(stateSpaceParameters.Y0d{numPartition});
            outputSystemParameters.nonlinearity{numPartition}=stateSpaceParameters.nonlinearity{numPartition+size(stateSpaceParameters.Ad,2)};

        end
        utilImplementPartitionEquationSystem(houtputSystemIn1,...
        houtputSystemIn2State,houtputSystemIn3Sel,...
        houtputSystemOut1,outputSystem,outputSystemParameters);
    else

        outputSystemParameters.StateParameter={strcat(stateSpaceParametersVarName,'.Cd'),(stateSpaceParameters.Cd)};
        outputSystemParameters.InputParameter={strcat(stateSpaceParametersVarName,'.Dd'),(stateSpaceParameters.Dd)};
        outputSystemParameters.BiasParameter={strcat(stateSpaceParametersVarName,'.Y0d'),(stateSpaceParameters.Y0d)};
        outputSystemParameters.AlgorithmDataType=hdlAlgorithmDataType;
        outputSystemParameters.SampleTime=compactButAccurateNum2Str(stateSpaceParameters.DiscreteSampleTime);


        utilImplementEquationSystem(houtputSystemIn1,...
        houtputSystemIn2State,houtputSystemIn3Sel,...
        houtputSystemOut1,outputSystem,outputSystemParameters,sschdlProductSumCustomLatency);
    end



    if numsolverIters>1


        add_line(hdlAlgorithmSystem,strcat(get_param(hhdlAlgorithmSystemIn,'Name'),'/1'),strcat(get_param(hinputRateTransitionBlk,'Name'),'/1'),...
        'autorouting','on');


        add_line(hdlAlgorithmSystem,strcat(get_param(hhdlAlgorithmSystemIn,'Name'),'/1'),strcat(get_param(hmatchingDelayBlk,'Name'),'/1'),...
        'autorouting','on');



        add_line(hdlAlgorithmSystem,strcat(get_param(hinputRateTransitionBlk,'Name'),'/1'),strcat(get_param(hstateUpdateSystem,'Name'),'/1'),...
        'autorouting','on');


        add_line(hdlAlgorithmSystem,strcat(get_param(hinputRateTransitionBlk,'Name'),'/1'),strcat(get_param(hmodeSelectionSystem,'Name'),'/1'),...
        'autorouting','on');


        add_line(hdlAlgorithmSystem,strcat(get_param(hstateUpdateSystem,'Name'),'/1'),strcat(get_param(hstateSystem,'Name'),'/2'),...
        'autorouting','on');


        add_line(hdlAlgorithmSystem,strcat(get_param(hstateSystem,'Name'),'/1'),strcat(get_param(hstateDelayBlk,'Name'),'/1'),...
        'autorouting','on');

        add_line(hdlAlgorithmSystem,strcat(get_param(hstateSystem,'Name'),'/2'),strcat(get_param(hstateUpdateSystem,'Name'),'/2'),...
        'autorouting','on');

        add_line(hdlAlgorithmSystem,strcat(get_param(hstateSystem,'Name'),'/2'),strcat(get_param(hstateRateTransitionBlk,'Name'),'/1'),...
        'autorouting','on');

        add_line(hdlAlgorithmSystem,strcat(get_param(hstateSystem,'Name'),'/3'),strcat(get_param(hstateUpdateSystem,'Name'),'/3'),...
        'autorouting','on');
        if~partitionFlag

            add_line(hdlAlgorithmSystem,strcat(get_param(hstateSystem,'Name'),'/3'),strcat(get_param(hmodeDelayBlk,'Name'),'/1'),...
            'autorouting','on');
        end

        add_line(hdlAlgorithmSystem,strcat(get_param(hmodeSelectionSystem,'Name'),'/1'),strcat(get_param(hstateSystem,'Name'),'/3'),...
        'autorouting','on');


        add_line(hdlAlgorithmSystem,strcat(get_param(hstateDelayBlk,'Name'),'/1'),strcat(get_param(hmodeSelectionSystem,'Name'),'/2'),...
        'autorouting','on');

        add_line(hdlAlgorithmSystem,strcat(get_param(hstateDelayBlk,'Name'),'/1'),strcat(get_param(hstateSystem,'Name'),'/1'),...
        'autorouting','on');



        if~partitionFlag

            add_line(hdlAlgorithmSystem,strcat(get_param(hmodeDelayBlk,'Name'),'/1'),strcat(get_param(hmodeRateTransitionBlk,'Name'),'/1'),...
            'autorouting','on');
        end


        add_line(hdlAlgorithmSystem,strcat(get_param(hstateRateTransitionBlk,'Name'),'/1'),strcat(get_param(houtputSystem,'Name'),'/2'),...
        'autorouting','on');



        if~partitionFlag
            add_line(hdlAlgorithmSystem,strcat(get_param(hmodeRateTransitionBlk,'Name'),'/1'),strcat(get_param(houtputSystem,'Name'),'/3'),...
            'autorouting','on');
        end

        add_line(hdlAlgorithmSystem,strcat(get_param(hmatchingDelayBlk,'Name'),'/1'),strcat(get_param(houtputSystem,'Name'),'/1'),...
        'autorouting','on');



        add_line(hdlAlgorithmSystem,strcat(get_param(houtputSystem,'Name'),'/1'),strcat(get_param(hhdlAlgorithmSystemOut,'Name'),'/1'),...
        'autorouting','on');
    else





        add_line(hdlAlgorithmSystem,strcat(get_param(hhdlAlgorithmSystemIn,'Name'),'/1'),strcat(get_param(hstateUpdateSystem,'Name'),'/1'),...
        'autorouting','on');


        add_line(hdlAlgorithmSystem,strcat(get_param(hhdlAlgorithmSystemIn,'Name'),'/1'),strcat(get_param(houtputSystem,'Name'),'/1'),...
        'autorouting','on');


        add_line(hdlAlgorithmSystem,strcat(get_param(hstateUpdateSystem,'Name'),'/1'),strcat(get_param(hstateDelayBlk,'Name'),'/1'),...
        'autorouting','on');


        add_line(hdlAlgorithmSystem,strcat(get_param(hstateDelayBlk,'Name'),'/1'),strcat(get_param(hstateUpdateSystem,'Name'),'/2'),...
        'autorouting','on');

        add_line(hdlAlgorithmSystem,strcat(get_param(hstateUpdateSystem,'Name'),'/1'),strcat(get_param(houtputSystem,'Name'),'/2'),...
        'autorouting','on');



        add_line(hdlAlgorithmSystem,strcat(get_param(houtputSystem,'Name'),'/1'),strcat(get_param(hhdlAlgorithmSystemOut,'Name'),'/1'),...
        'autorouting','on');







        hSelConstantBlk=add_block('hdlsllib/Sources/Constant',strcat(hdlAlgorithmSystem,'/Sel'),...
        'MakeNameUnique','on',...
        'Value',strcat('zeros(1,',int2str(size(stateSpaceParameters.Ad,2)),')'),...
        'OutDataTypeStr','uint32',...
        'SampleTime','-1',...
        'Position',[1700,1460,1730,1490]);



        add_line(hdlAlgorithmSystem,strcat(get_param(hSelConstantBlk,'Name'),'/1'),strcat(get_param(hstateUpdateSystem,'Name'),'/3'),...
        'autorouting','on');

    end

    if partitionFlag
        if any(stateSpaceParameters.NumberOfSwitchingModes(size(stateSpaceParameters.Ad,2)+1:end)>1)

            hmodeSelectionSystemOut=utilAddSubsystem(hdlAlgorithmSystem,'Mode Selection',[2260,1418,2295,1452],'white');
            modeSelectionSystemOut=getfullname(hmodeSelectionSystemOut);

            hmodeSelectionSystemOutIn1=add_block('hdlsllib/Sources/In1',strcat(modeSelectionSystemOut,'/In1'),...
            'MakeNameUnique','on');
            hmodeSelectionSystemOutIn2State=add_block('hdlsllib/Sources/In1',strcat(modeSelectionSystemOut,'/In2'),...
            'MakeNameUnique','on');

            hmodeSelectionSystemOutOut1Mode=add_block('hdlsllib/Sinks/Out1',strcat(modeSelectionSystemOut,'/Out1'),...
            'MakeNameUnique','on');

            utilImplementPartitionModeSelectionSystem(hmodeSelectionSystemOutIn1,hmodeSelectionSystemOutIn2State,...
            hmodeSelectionSystemOutOut1Mode,modeSelectionSystemOut,stateSpaceParametersVarName,stateSpaceParameters,numsolverIters,1);


            add_line(hdlAlgorithmSystem,strcat(get_param(hmodeSelectionSystemOut,'Name'),'/1'),strcat(get_param(houtputSystem,'Name'),'/3'),...
            'autorouting','on');

            add_line(hdlAlgorithmSystem,strcat(get_param(hstateRateTransitionBlk,'Name'),'/1'),strcat(get_param(hmodeSelectionSystemOut,'Name'),'/2'),...
            'autorouting','on');

            add_line(hdlAlgorithmSystem,strcat(get_param(hmatchingDelayBlk,'Name'),'/1'),strcat(get_param(hmodeSelectionSystemOut,'Name'),'/1'),...
            'autorouting','on');
        else
            hSelConstantBlk1=add_block('hdlsllib/Sources/Constant',strcat(hdlAlgorithmSystem,'/Sel'),...
            'MakeNameUnique','on',...
            'Value','0',...
            'OutDataTypeStr','uint32',...
            'SampleTime','-1',...
            'Position',[1900,1460,1930,1490]);
            add_line(hdlAlgorithmSystem,strcat(get_param(hSelConstantBlk1,'Name'),'/1'),strcat(get_param(houtputSystem,'Name'),'/3'),...
            'autorouting','on');
        end
    end



end
