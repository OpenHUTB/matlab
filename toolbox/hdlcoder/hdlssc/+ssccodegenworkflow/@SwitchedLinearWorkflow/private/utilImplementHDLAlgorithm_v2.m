function utilImplementHDLAlgorithm_v2(hhdlAlgorithmSystem,hhdlAlgorithmSystemIn,hhdlAlgorithmSystemOut,...
    stateSpaceParametersVarName,stateSpaceParameters,numSolverIters,hdlAlgorithmDataType,...
    sschdlProductSumCustomLatency,hhdlAlgorithmSystemEnableOut2,singleRateModel,linearizationInfo)




    hdlAlgorithmSystem=getfullname(hhdlAlgorithmSystem);

    if numSolverIters==1&&stateSpaceParameters.NumberOfSwitchingModes>1
        singleRateModel=true;
    end


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

        if singleRateModel
            inputSampleTime=compactButAccurateNum2Str(stateSpaceParameters.DiscreteSampleTime/double(numSolverIters));
        else
            inputSampleTime=compactButAccurateNum2Str(stateSpaceParameters.DiscreteSampleTime);
        end



        hhdlAlgorithmSystemIn=add_block('hdlsllib/Sources/Constant',strcat(hdlAlgorithmSystem,'/In1'),...
        'MakeNameUnique','on',...
        'Value',strcat(mixedDataType,'(','0',')'),...
        'SampleTime',inputSampleTime,...
        'Position',[1520,1283,1550,1297]);
    else

        set_param(hhdlAlgorithmSystemIn,'Position',[1520,1283,1550,1297]);
    end


    if isempty(hhdlAlgorithmSystemOut)



        hhdlAlgorithmSystemOut=add_block('hdlsllib/Sinks/Terminator',strcat(hdlAlgorithmSystem,'/Out1'),...
        'MakeNameUnique','on',...
        'Position',[2320,1273,2350,1287]);
    else

        set_param(hhdlAlgorithmSystemOut,'Position',[2320,1273,2350,1287]);
    end



    if numSolverIters>1
        if~singleRateModel


            hinputRateTransitionBlk=add_block('hdlsllib/Signal Attributes/Rate Transition',strcat(hdlAlgorithmSystem,'/Rate Transition'),...
            'MakeNameUnique','on',...
            'OutPortSampleTimeOpt','Multiple of input port sample time',...
            'OutPortSampleTimeMultiple',strcat('1/',num2str(numSolverIters)),...
            'Integrity','off',...
            'Position',[1600,1269,1640,1311]);

            hstateRateTransitionBlk=add_block('hdlsllib/Signal Attributes/Rate Transition',strcat(hdlAlgorithmSystem,'/Rate Transition1'),...
            'MakeNameUnique','on',...
            'OutPortSampleTimeOpt','Multiple of input port sample time',...
            'OutPortSampleTimeMultiple',num2str(numSolverIters),...
            'Position',[2090,1259,2130,1301]);

            hmodeRateTransitionBlk=add_block('hdlsllib/Signal Attributes/Rate Transition',strcat(hdlAlgorithmSystem,'/Rate Transition2'),...
            'MakeNameUnique','on',...
            'OutPortSampleTimeOpt','Multiple of input port sample time',...
            'OutPortSampleTimeMultiple',num2str(numSolverIters),...
            'Position',[2090,1339,2130,1381]);
        end


        hstateSystem=utilAddSubsystem(hdlAlgorithmSystem,'Mode Iteration Manager',[1840,1302,1925,1378],'white');
        stateSystem=getfullname(hstateSystem);

        hstateSystemIn1StateNew=add_block('hdlsllib/Sources/In1',strcat(stateSystem,'/In1'),...
        'MakeNameUnique','on');
        hstateSystemIn2ModeNew=add_block('hdlsllib/Sources/In1',strcat(stateSystem,'/In2'),...
        'MakeNameUnique','on');

        hstateSystemOut1State=add_block('hdlsllib/Sinks/Out1',strcat(stateSystem,'/Out1'),...
        'OutDataTypeStr',mixedDataType,...
        'MakeNameUnique','on');
        hstateSystemOut2Mode=add_block('hdlsllib/Sinks/Out1',strcat(stateSystem,'/Out2'),...
        'MakeNameUnique','on');
        if~isempty(hhdlAlgorithmSystemEnableOut2)
            hstateSystemOut3Enable=add_block('hdlsllib/Sinks/Out1',strcat(stateSystem,'/Valid Out'),...
            'MakeNameUnique','on');
        else
            hstateSystemOut3Enable=[];
        end


        utilImplementStateSystem_v2(hstateSystemIn1StateNew,...
        hstateSystemIn2ModeNew,hstateSystemOut1State,...
        hstateSystemOut2Mode,hstateSystem,stateSpaceParameters,numSolverIters,...
        initialState,hstateSystemOut3Enable,singleRateModel);


        if~singleRateModel
            delayLength='1';
        else
            delayLength=int2str(numSolverIters);
        end
        hmatchingDelayBlk=add_block('hdlsllib/Discrete/Delay',strcat(hdlAlgorithmSystem,'/Delay1'),...
        'MakeNameUnique','on',...
        'DelayLength',delayLength,...
        'Position',[1740,1178,1775,1212]);
    else


        hmatchingDelayBlk=add_block('hdlsllib/Discrete/Delay',strcat(hdlAlgorithmSystem,'/Delay1'),...
        'MakeNameUnique','on',...
        'DelayLength','1',...
        'Position',[2095,1208,2130,1242]);


        henableConstantBlk=add_block('hdlsllib/Sources/Constant',strcat(hdlAlgorithmSystem,'/Valid Out'),...
        'MakeNameUnique','on',...
        'Value','1',...
        'SampleTime',compactButAccurateNum2Str(stateSpaceParameters.DiscreteSampleTime),...
        'OutDataTypeStr','boolean',...
        'Position',[1955,1425,1985,1455]);


        hinitialStateConstantBlk=add_block('hdlsllib/Sources/Constant',strcat(hdlAlgorithmSystem,'/X0'),...
        'MakeNameUnique','on',...
        'Value',initialState,...
        'SampleTime',compactButAccurateNum2Str(stateSpaceParameters.DiscreteSampleTime),...
        'Position',[1985,1479,2015,1511]);



        hdelayBlk1=add_block('hdlsllib/Discrete/Delay',strcat(hdlAlgorithmSystem,'/Delay1'),...
        'MakeNameUnique','on',...
        'DelayLength','2',...
        'Position',[2015,1423,2050,1457]);

        hstateSelectSwitchBlk=add_block('hdlsllib/Signal Routing/Switch',strcat(hdlAlgorithmSystem,'/Switch'),...
        'MakeNameUnique','on',...
        'Position',[2130,1420,2180,1460],...
        'Criteria','u2 ~= 0');


    end

    if stateSpaceParameters.NumberOfSwitchingModes>1


        hmodeSelectionSystem=utilAddSubsystem(hdlAlgorithmSystem,'Mode Selection',[1725,1330,1785,1390],'white');
        modeSelectionSystem=getfullname(hmodeSelectionSystem);

        hmodeSelectionSystemIn1=add_block('hdlsllib/Sources/In1',strcat(modeSelectionSystem,'/In1'),...
        'MakeNameUnique','on');
        hmodeSelectionSystemIn2State=add_block('hdlsllib/Sources/In1',strcat(modeSelectionSystem,'/In2'),...
        'MakeNameUnique','on');

        hmodeSelectionSystemOut1StateMode=add_block('hdlsllib/Sinks/Out1',strcat(modeSelectionSystem,'/Out1'),...
        'MakeNameUnique','on');
        hmodeSelectionSystemOut2OutputMode=add_block('hdlsllib/Sinks/Out1',strcat(modeSelectionSystem,'/Out2'),...
        'MakeNameUnique','on');


        utilImplementModeSelectionSystem(hmodeSelectionSystemIn1,hmodeSelectionSystemIn2State,...
        hmodeSelectionSystemOut1StateMode,hmodeSelectionSystemOut2OutputMode,...
        modeSelectionSystem,stateSpaceParametersVarName,stateSpaceParameters,numSolverIters);
    else






        hSelConstantBlk=add_block('hdlsllib/Sources/Constant',strcat(hdlAlgorithmSystem,'/Sel'),...
        'MakeNameUnique','on',...
        'Value','0',...
        'OutDataTypeStr','uint32',...
        'SampleTime',num2str(stateSpaceParameters.DiscreteSampleTime),...
        'Position',[1680,1585,1710,1615]);

    end



    hstateUpdateSystem=utilAddSubsystem(hdlAlgorithmSystem,'State Update',[1985,1239,2045,1321],'white');
    stateUpdateSystem=getfullname(hstateUpdateSystem);

    hstateUpdateSystemIn1=add_block('hdlsllib/Sources/In1',strcat(stateUpdateSystem,'/In1'),...
    'MakeNameUnique','on');
    hstateUpdateSystemIn2State=add_block('hdlsllib/Sources/In1',strcat(stateUpdateSystem,'/State'),...
    'MakeNameUnique','on');
    hstateUpdateSystemIn3Sel=add_block('hdlsllib/Sources/In1',strcat(stateUpdateSystem,'/Sel'),...
    'MakeNameUnique','on');

    hstateUpdateSystemOut1=add_block('hdlsllib/Sinks/Out1',strcat(stateUpdateSystem,'/Out1'),...
    'OutDataTypeStr',mixedDataType,...
    'MakeNameUnique','on');

    stateUpdateSystemParameters=struct;
    stateUpdateSystemParameters.StateParameter={strcat(stateSpaceParametersVarName,'.Ad'),(stateSpaceParameters.Ad)};
    stateUpdateSystemParameters.InputParameter={strcat(stateSpaceParametersVarName,'.Bd'),(stateSpaceParameters.Bd)};
    stateUpdateSystemParameters.BiasParameter={strcat(stateSpaceParametersVarName,'.F0d'),(stateSpaceParameters.F0d)};
    if isfield(stateSpaceParameters,'Kxd')&&~isempty(stateSpaceParameters.Kxd)
        stateUpdateSystemParameters.CurrentSourceParameter={strcat(stateSpaceParametersVarName,'.Kxd'),(stateSpaceParameters.Kxd)};

        hstateUpdateSystemIn4J=add_block('hdlsllib/Sources/In1',strcat(stateUpdateSystem,'/J'),...
        'MakeNameUnique','on');
    else
        hstateUpdateSystemIn4J=[];
    end


    stateUpdateSystemParameters.AlgorithmDataType=hdlAlgorithmDataType;
    stateUpdateSystemParameters.SampleTime=compactButAccurateNum2Str(stateSpaceParameters.DiscreteSampleTime/double(numSolverIters));
    utilImplementEquationSystem(hstateUpdateSystemIn1,...
    hstateUpdateSystemIn2State,hstateUpdateSystemIn3Sel,...
    hstateUpdateSystemOut1,stateUpdateSystem,stateUpdateSystemParameters,sschdlProductSumCustomLatency,hstateUpdateSystemIn4J);



    if numSolverIters>1
        stateDelayBlkPos=[1610,1359,1640,1391];
    else
        stateDelayBlkPos=[2065,1264,2095,1296];

    end

    hstateDelayBlk=add_block('hdlsllib/Discrete/Delay',strcat(hdlAlgorithmSystem,'/State Delay'),...
    'MakeNameUnique','on',...
    'DelayLength','1',...
    'InitialCondition',initialState,...
    'Position',stateDelayBlkPos);


    houtputSystem=utilAddSubsystem(hdlAlgorithmSystem,'Output',[2210,1239,2270,1321],'white');
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
    outputSystemParameters.StateParameter={strcat(stateSpaceParametersVarName,'.Cd'),(stateSpaceParameters.Cd)};
    outputSystemParameters.InputParameter={strcat(stateSpaceParametersVarName,'.Dd'),(stateSpaceParameters.Dd)};
    outputSystemParameters.BiasParameter={strcat(stateSpaceParametersVarName,'.Y0d'),(stateSpaceParameters.Y0d)};
    if isfield(stateSpaceParameters,'Kyd')&&~isempty(stateSpaceParameters.Kyd)
        outputSystemParameters.CurrentSourceParameter={strcat(stateSpaceParametersVarName,'.Kyd'),(stateSpaceParameters.Kyd)};

        houtputSystemIn4J=add_block('hdlsllib/Sources/In1',strcat(outputSystem,'/J'),...
        'MakeNameUnique','on');
    else
        houtputSystemIn4J=[];
    end
    outputSystemParameters.AlgorithmDataType=hdlAlgorithmDataType;

    if singleRateModel
        outputSystemParameters.SampleTime=compactButAccurateNum2Str(stateSpaceParameters.DiscreteSampleTime/double(numSolverIters));
    else
        outputSystemParameters.SampleTime=compactButAccurateNum2Str(stateSpaceParameters.DiscreteSampleTime);
    end
    utilImplementEquationSystem(houtputSystemIn1,...
    houtputSystemIn2State,houtputSystemIn3Sel,...
    houtputSystemOut1,outputSystem,outputSystemParameters,sschdlProductSumCustomLatency,houtputSystemIn4J);




    if isfield(stateSpaceParameters,'Kyd')&&~(isempty(stateSpaceParameters.Kyd)&&isempty(stateSpaceParameters.Kxd))
        hlinearModeSel=utilAddSubsystem(hdlAlgorithmSystem,'Mode Selection',[1680,1404,1780,1446],'white');
        linearModeSel=getfullname(hlinearModeSel);
        hlinearModeSelIn1=add_block('hdlsllib/Sources/In1',strcat(linearModeSel,'/In1'),...
        'MakeNameUnique','on');
        hlinearModeSelStateIn2=add_block('hdlsllib/Sources/In1',strcat(linearModeSel,'/State'),...
        'MakeNameUnique','on');
        hlinearModeSelJOut1=add_block('hdlsllib/Sinks/Out1',strcat(linearModeSel,'/J out'),...
        'MakeNameUnique','on');

        utilImplementLinearizedModeSelection(hlinearModeSel,hlinearModeSelIn1,hlinearModeSelStateIn2,...
        hlinearModeSelJOut1,linearizationInfo,hdlAlgorithmDataType);

        hCurrentDelayBlk=add_block('hdlsllib/Discrete/Delay',strcat(hdlAlgorithmSystem,'/J Delay'),...
        'MakeNameUnique','on',...
        'DelayLength','1',...
        'Position',[2045,1409,2075,1441]);









        if numSolverIters>1
            hStateSource=hstateSystem;
        else
            hStateSource=hstateSelectSwitchBlk;
        end

        outPortList={strcat(get_param(hhdlAlgorithmSystemIn,'Name'),'/1'),...
        strcat(get_param(hStateSource,'Name'),'/1'),...
        strcat(get_param(hlinearModeSel,'Name'),'/1'),...
        strcat(get_param(hlinearModeSel,'Name'),'/1'),...
        strcat(get_param(hCurrentDelayBlk,'Name'),'/1')};
        inPortList={strcat(get_param(hlinearModeSel,'Name'),'/1'),...
        strcat(get_param(hlinearModeSel,'Name'),'/2'),...
        strcat(get_param(hCurrentDelayBlk,'Name'),'/1'),...
        strcat(get_param(hstateUpdateSystem,'Name'),'/4'),...
        strcat(get_param(houtputSystem,'Name'),'/4')};

        add_line(hdlAlgorithmSystem,outPortList,inPortList,'autorouting','smart');

    end





    if stateSpaceParameters.NumberOfSwitchingModes>1
        hmodeDelayBlk=add_block('hdlsllib/Discrete/Delay',strcat(hdlAlgorithmSystem,'/Delay'),...
        'MakeNameUnique','on',...
        'DelayLength','1',...
        'Position',[1995,1343,2030,1377]);



        if singleRateModel
            add_line(hdlAlgorithmSystem,strcat(get_param(hhdlAlgorithmSystemIn,'Name'),'/1'),strcat(get_param(hmodeSelectionSystem,'Name'),'/1'),...
            'autorouting','on');


            add_line(hdlAlgorithmSystem,strcat(get_param(hmodeDelayBlk,'Name'),'/1'),strcat(get_param(houtputSystem,'Name'),'/3'),...
            'autorouting','on');
        end


        if numSolverIters<=1


            add_line(hdlAlgorithmSystem,strcat(get_param(hstateSelectSwitchBlk,'Name'),'/1'),strcat(get_param(hmodeSelectionSystem,'Name'),'/2'),...
            'autorouting','on');

            add_line(hdlAlgorithmSystem,strcat(get_param(hmodeSelectionSystem,'Name'),'/1'),strcat(get_param(hstateUpdateSystem,'Name'),'/3'),...
            'autorouting','on');

            add_line(hdlAlgorithmSystem,strcat(get_param(hmodeSelectionSystem,'Name'),'/2'),strcat(get_param(hmodeDelayBlk,'Name'),'/1'),...
            'autorouting','on');
        end

    else

        add_line(hdlAlgorithmSystem,strcat(get_param(hSelConstantBlk,'Name'),'/1'),strcat(get_param(hstateUpdateSystem,'Name'),'/3'),...
        'autorouting','on');

        add_line(hdlAlgorithmSystem,strcat(get_param(hSelConstantBlk,'Name'),'/1'),strcat(get_param(houtputSystem,'Name'),'/3'),...
        'autorouting','on');


    end




    if numSolverIters>1
        if singleRateModel



            add_line(hdlAlgorithmSystem,strcat(get_param(hhdlAlgorithmSystemIn,'Name'),'/1'),strcat(get_param(hstateUpdateSystem,'Name'),'/1'),...
            'autorouting','on');


            add_line(hdlAlgorithmSystem,strcat(get_param(hstateSystem,'Name'),'/1'),strcat(get_param(houtputSystem,'Name'),'/2'),...
            'autorouting','on');
            if~isempty(hhdlAlgorithmSystemEnableOut2)
                add_line(hdlAlgorithmSystem,strcat(get_param(hstateSystem,'Name'),'/3'),strcat(get_param(hhdlAlgorithmSystemEnableOut2,'Name'),'/1'),...
                'autorouting','on');
            end


        else


            add_line(hdlAlgorithmSystem,strcat(get_param(hhdlAlgorithmSystemIn,'Name'),'/1'),strcat(get_param(hinputRateTransitionBlk,'Name'),'/1'),...
            'autorouting','on');


            add_line(hdlAlgorithmSystem,strcat(get_param(hinputRateTransitionBlk,'Name'),'/1'),strcat(get_param(hstateUpdateSystem,'Name'),'/1'),...
            'autorouting','on');


            add_line(hdlAlgorithmSystem,strcat(get_param(hinputRateTransitionBlk,'Name'),'/1'),strcat(get_param(hmodeSelectionSystem,'Name'),'/1'),...
            'autorouting','on');

            add_line(hdlAlgorithmSystem,strcat(get_param(hstateSystem,'Name'),'/1'),strcat(get_param(hstateRateTransitionBlk,'Name'),'/1'),...
            'autorouting','on');



            add_line(hdlAlgorithmSystem,strcat(get_param(hstateRateTransitionBlk,'Name'),'/1'),strcat(get_param(houtputSystem,'Name'),'/2'),...
            'autorouting','on');


            add_line(hdlAlgorithmSystem,strcat(get_param(hmodeDelayBlk,'Name'),'/1'),strcat(get_param(hmodeRateTransitionBlk,'Name'),'/1'),...
            'autorouting','on');


            add_line(hdlAlgorithmSystem,strcat(get_param(hmodeRateTransitionBlk,'Name'),'/1'),strcat(get_param(houtputSystem,'Name'),'/3'),...
            'autorouting','on');

        end


        add_line(hdlAlgorithmSystem,strcat(get_param(hhdlAlgorithmSystemIn,'Name'),'/1'),strcat(get_param(hmatchingDelayBlk,'Name'),'/1'),...
        'autorouting','on');


        add_line(hdlAlgorithmSystem,strcat(get_param(hstateDelayBlk,'Name'),'/1'),strcat(get_param(hmodeSelectionSystem,'Name'),'/2'),...
        'autorouting','on');

        add_line(hdlAlgorithmSystem,strcat(get_param(hmodeSelectionSystem,'Name'),'/1'),strcat(get_param(hstateSystem,'Name'),'/2'),...
        'autorouting','on');


        add_line(hdlAlgorithmSystem,strcat(get_param(hstateUpdateSystem,'Name'),'/1'),strcat(get_param(hstateDelayBlk,'Name'),'/1'),...
        'autorouting','on');


        add_line(hdlAlgorithmSystem,strcat(get_param(hstateSystem,'Name'),'/1'),strcat(get_param(hstateUpdateSystem,'Name'),'/2'),...
        'autorouting','on');

        add_line(hdlAlgorithmSystem,strcat(get_param(hstateSystem,'Name'),'/2'),strcat(get_param(hstateUpdateSystem,'Name'),'/3'),...
        'autorouting','on');

        add_line(hdlAlgorithmSystem,strcat(get_param(hmodeSelectionSystem,'Name'),'/2'),strcat(get_param(hmodeDelayBlk,'Name'),'/1'),...
        'autorouting','on');


        add_line(hdlAlgorithmSystem,strcat(get_param(hstateDelayBlk,'Name'),'/1'),strcat(get_param(hstateSystem,'Name'),'/1'),...
        'autorouting','on');


        add_line(hdlAlgorithmSystem,strcat(get_param(hmatchingDelayBlk,'Name'),'/1'),strcat(get_param(houtputSystem,'Name'),'/1'),...
        'autorouting','on');



        add_line(hdlAlgorithmSystem,strcat(get_param(houtputSystem,'Name'),'/1'),strcat(get_param(hhdlAlgorithmSystemOut,'Name'),'/1'),...
        'autorouting','on');


    else


        add_line(hdlAlgorithmSystem,strcat(get_param(hhdlAlgorithmSystemIn,'Name'),'/1'),strcat(get_param(hstateUpdateSystem,'Name'),'/1'),...
        'autorouting','on');


        add_line(hdlAlgorithmSystem,strcat(get_param(hhdlAlgorithmSystemIn,'Name'),'/1'),strcat(get_param(hmatchingDelayBlk,'Name'),'/1'),...
        'autorouting','on');


        add_line(hdlAlgorithmSystem,strcat(get_param(hmatchingDelayBlk,'Name'),'/1'),strcat(get_param(houtputSystem,'Name'),'/1'),...
        'autorouting','on');

        add_line(hdlAlgorithmSystem,strcat(get_param(hstateUpdateSystem,'Name'),'/1'),strcat(get_param(hstateDelayBlk,'Name'),'/1'),...
        'autorouting','on');

        add_line(hdlAlgorithmSystem,strcat(get_param(hstateDelayBlk,'Name'),'/1'),strcat(get_param(hstateSelectSwitchBlk,'Name'),'/1'),...
        'autorouting','on');




        add_line(hdlAlgorithmSystem,strcat(get_param(hstateSelectSwitchBlk,'Name'),'/1'),strcat(get_param(hstateUpdateSystem,'Name'),'/2'),...
        'autorouting','on');

        add_line(hdlAlgorithmSystem,strcat(get_param(hstateSelectSwitchBlk,'Name'),'/1'),strcat(get_param(houtputSystem,'Name'),'/2'),...
        'autorouting','on');



        add_line(hdlAlgorithmSystem,strcat(get_param(houtputSystem,'Name'),'/1'),strcat(get_param(hhdlAlgorithmSystemOut,'Name'),'/1'),...
        'autorouting','on');


        add_line(hdlAlgorithmSystem,strcat(get_param(henableConstantBlk,'Name'),'/1'),strcat(get_param(hdelayBlk1,'Name'),'/1'),...
        'autorouting','on');


        add_line(hdlAlgorithmSystem,strcat(get_param(hdelayBlk1,'Name'),'/1'),strcat(get_param(hstateSelectSwitchBlk,'Name'),'/2'),...
        'autorouting','on');


        add_line(hdlAlgorithmSystem,strcat(get_param(hinitialStateConstantBlk,'Name'),'/1'),strcat(get_param(hstateSelectSwitchBlk,'Name'),'/3'),...
        'autorouting','on');

    end
    Simulink.BlockDiagram.arrangeSystem(hdlAlgorithmSystem,'FullLayout','True','Animation','False');

end


