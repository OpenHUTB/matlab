function[hModeSelection,MlBlkInfo]=utilAddModeSelectionLogic(parent,clumpInfo,...
    position,numSolverIter,dataType,globalData,latencyStrategy)







    hModeSelection=utilAddSubsystem(parent,'Mode Selection',position);
    modeSelectionName=getfullname(hModeSelection);


    hInU=add_block('hdlsllib/Sources/In1',strcat(modeSelectionName,'/U'),...
    'MakeNameUnique','on',...
    'Position',[125,158,155,172]);


    hInX=add_block('hdlsllib/Sources/In1',strcat(modeSelectionName,'/State'),...
    'MakeNameUnique','on',...
    'Position',[35,78,65,92]);



    hInModeVec=add_block('hdlsllib/Sources/In1',strcat(modeSelectionName,'/Mode Vector In'),...
    'MakeNameUnique','on',...
    'Position',[245,83,275,97]);

    hInT=add_block('hdlsllib/Sources/In1',strcat(modeSelectionName,'/t'),...
    'MakeNameUnique','on',...
    'Position',[125,203,155,217]);

    fModechart=matlab.internal.feature("SSC2HDLModechart");

    if(fModechart&&globalData.numQs>0)

        hInQ=add_block('hdlsllib/Sources/In1',strcat(modeSelectionName,'/Q'),...
        'MakeNameUnique','on',...
        'Position',[225,158,255,172]);


        hInCI=add_block('hdlsllib/Sources/In1',strcat(modeSelectionName,'/CI'),...
        'MakeNameUnique','on',...
        'Position',[325,78,355,92]);
    end

    if numSolverIter>1
        hInXnext=add_block('hdlsllib/Sources/In1',strcat(modeSelectionName,'/Next State'),...
        'MakeNameUnique','on',...
        'Position',[35,153,65,167]);
        hInCounter=add_block('hdlsllib/Sources/In1',strcat(modeSelectionName,'/Counter'),...
        'MakeNameUnique','on',...
        'Position',[35,153,65,167]);
    end





    hConfigOut=add_block('hdlsllib/Sinks/Out1',strcat(modeSelectionName,'/Sel Out'),...
    'MakeNameUnique','on',...
    'Position',[675,148,705,162]);

    hModeVecOut=add_block('hdlsllib/Sinks/Out1',strcat(modeSelectionName,'/Mode Vector In'),...
    'MakeNameUnique','on',...
    'Position',[425,93,455,107]);



    if numSolverIter>1

        hCompare=add_block('simulink/Logic and Bit Operations/Compare To Zero',strcat(modeSelectionName,'/Mode Vector In'),...
        'MakeNameUnique','on',...
        'relop','==',...
        'Position',[35,110,65,140]);

        hstateSelectSwitchBlk=add_block('hdlsllib/Signal Routing/Switch',strcat(modeSelectionName,'/Switch'),...
        'MakeNameUnique','on',...
        'Position',[100,105,150,145],...
        'Criteria','u2 ~= 0');
    end


    numStates=numel(clumpInfo.ReferencedStates);
    numInputs=numel(clumpInfo.ReferencedInputs);
    numQs=numel(clumpInfo.ReferencedQs);
    numCIs=numel(clumpInfo.ReferencedCIs);

    if numInputs<1
        numInputs=1;
    end
    if numStates<1
        numStates=1;
    end

    if(globalData.numQs>0&&numQs<1)
        numQs=1;
    end

    if(globalData.numQs>0&&numCIs<1)
        numCIs=1;
    end

    if(fModechart&&globalData.numQs>0)
        if(numCIs<1)
            numCIs=1;
        end
        argDims={[numStates,1],...
        [numInputs,1],...
        [1,1],...
        [1,numQs],...
        [1,numCIs]};
    else
        argDims={[numStates,1],...
        [numInputs,1],...
        [1,1]};
    end



    [hModeCompute,MlBlkInfo]=utilAddML2SLSubsystem(modeSelectionName,clumpInfo.ModeFcn,...
    [45,161,180,229],dataType,argDims,globalData.sampleTime,latencyStrategy,globalData.numQs>0);

    featIntModes=matlab.internal.feature("SSC2HDLIntegerModes");
    if(featIntModes)


        dtc=Simulink.findBlocksOfType(hModeCompute,'DataTypeConversion');

        for i=1:length(dtc)
            set_param(getfullname(dtc(i)),'SaturateOnIntegerOverflow','off');
        end


        hModeDTC=add_block('hdlsllib/Signal Attributes/Data Type Conversion',strcat(modeSelectionName,'/Data Type Conversion'),...
        'MakeNameUnique','on',...
        'Position',[225,266,300,304],...
        'OutDataTypeStr','int32',...
        'RndMeth','Nearest');
    end


    hModeSel=add_block('hdlsllib/Signal Routing/Selector',strcat(modeSelectionName,'/Selector'),...
    'MakeNameUnique','on',...
    'Indices',strcat('[',int2str(clumpInfo.ReferencedModes(clumpInfo.MatrixModes)'),']'),...
    'InputPortWidth','-1',...
    'Position',[435,136,475,174]);

    modeVectorSize=globalData.totalModes;


    linePorts=cell(7+1*(modeVectorSize(1)>1)+4*(numSolverIter>1),2);

    linePorts(1,:)={strcat(get_param(hInU,'name'),'/1'),...
    strcat(get_param(hModeCompute,'name'),'/2')};

    linePorts(2,:)={strcat(get_param(hInT,'name'),'/1'),...
    strcat(get_param(hModeCompute,'name'),'/3')};

    if(modeVectorSize(1)==1)
        hTerm=add_block('hdlsllib/Sinks/Terminator',strcat(modeSelectionName,'/term'),...
        'MakeNameUnique','on',...
        'Position',[215,81,285,114]);

        if(featIntModes)
            linePorts(3,:)={strcat(get_param(hModeDTC,'name'),'/1'),...
            strcat(get_param(hModeSel,'name'),'/1')};

            linePorts(12,:)={strcat(get_param(hModeCompute,'name'),'/1'),...
            strcat(get_param(hModeDTC,'name'),'/1')};

            linePorts(5,:)={strcat(get_param(hModeDTC,'name'),'/1'),...
            strcat(get_param(hModeVecOut,'name'),'/1')};
        else
            linePorts(3,:)={strcat(get_param(hModeCompute,'name'),'/1'),...
            strcat(get_param(hModeSel,'name'),'/1')};

            linePorts(5,:)={strcat(get_param(hModeCompute,'name'),'/1'),...
            strcat(get_param(hModeVecOut,'name'),'/1')};
        end


        linePorts(4,:)={strcat(get_param(hInModeVec,'name'),'/1'),...
        strcat(get_param(hTerm,'name'),'/1')};

        linePorts(6,:)={strcat(get_param(hModeSel,'name'),'/1'),...
        strcat(get_param(hConfigOut,'name'),'/1')};
        if numSolverIter>1
            linePorts(7,:)={strcat(get_param(hInX,'name'),'/1'),...
            strcat(get_param(hstateSelectSwitchBlk,'name'),'/1')};

            linePorts(8,:)={strcat(get_param(hInXnext,'name'),'/1'),...
            strcat(get_param(hstateSelectSwitchBlk,'name'),'/3')};

            linePorts(9,:)={strcat(get_param(hInCounter,'name'),'/1'),...
            strcat(get_param(hCompare,'name'),'/1')};

            linePorts(10,:)={strcat(get_param(hCompare,'name'),'/1'),...
            strcat(get_param(hstateSelectSwitchBlk,'name'),'/2')};

            linePorts(11,:)={strcat(get_param(hstateSelectSwitchBlk,'name'),'/1'),...
            strcat(get_param(hModeCompute,'name'),'/1')};
        else
            linePorts(7,:)={strcat(get_param(hInX,'name'),'/1'),...
            strcat(get_param(hModeCompute,'name'),'/1')};
        end

        add_line(modeSelectionName,linePorts(:,1),linePorts(:,2),'AutoRouting','smart')
    else

        hAssign=add_block('hdlsllib/Math Operations/Assignment',strcat(modeSelectionName,'/Mode Assign'),...
        'MakeNameUnique','on',...
        'Position',[315,81,385,114],...
        'IndexParamArray',{strcat('[',num2str(clumpInfo.ReferencedModes(clumpInfo.OwnedModes)'),']')});

        linePorts(3,:)={strcat(get_param(hInModeVec,'name'),'/1'),...
        strcat(get_param(hAssign,'name'),'/1')};

        linePorts(4,:)={strcat(get_param(hAssign,'name'),'/1'),...
        strcat(get_param(hModeVecOut,'name'),'/1')};

        linePorts(5,:)={strcat(get_param(hAssign,'name'),'/1'),...
        strcat(get_param(hModeSel,'name'),'/1')};
        linePorts(6,:)={strcat(get_param(hModeSel,'name'),'/1'),...
        strcat(get_param(hConfigOut,'name'),'/1')};
        if numSolverIter>1
            linePorts(7,:)={strcat(get_param(hInX,'name'),'/1'),...
            strcat(get_param(hstateSelectSwitchBlk,'name'),'/1')};

            linePorts(8,:)={strcat(get_param(hInXnext,'name'),'/1'),...
            strcat(get_param(hstateSelectSwitchBlk,'name'),'/3')};

            linePorts(9,:)={strcat(get_param(hInCounter,'name'),'/1'),...
            strcat(get_param(hCompare,'name'),'/1')};

            linePorts(10,:)={strcat(get_param(hCompare,'name'),'/1'),...
            strcat(get_param(hstateSelectSwitchBlk,'name'),'/2')};

            linePorts(11,:)={strcat(get_param(hstateSelectSwitchBlk,'name'),'/1'),...
            strcat(get_param(hModeCompute,'name'),'/1')};

            lastLine=11;
        else
            linePorts(7,:)={strcat(get_param(hInX,'name'),'/1'),...
            strcat(get_param(hModeCompute,'name'),'/1')};

            lastLine=7;
        end

        if(featIntModes)
            linePorts(lastLine+1,:)={strcat(get_param(hModeDTC,'name'),'/1'),...
            strcat(get_param(hAssign,'name'),'/2')};

            linePorts(lastLine+2,:)={strcat(get_param(hModeCompute,'name'),'/1'),...
            strcat(get_param(hModeDTC,'name'),'/1')};
        else
            linePorts(lastLine+1,:)={strcat(get_param(hModeCompute,'name'),'/1'),...
            strcat(get_param(hAssign,'name'),'/2')};
        end

        add_line(modeSelectionName,linePorts(:,1),linePorts(:,2),'AutoRouting','smart')
    end

    if(fModechart&&numQs>0)
        linePorts={};
        linePorts(1,:)={strcat(get_param(hInQ,'name'),'/1'),...
        strcat(get_param(hModeCompute,'name'),'/4')};

        linePorts(2,:)={strcat(get_param(hInCI,'name'),'/1'),...
        strcat(get_param(hModeCompute,'name'),'/5')};

        add_line(modeSelectionName,linePorts(:,1),linePorts(:,2),'AutoRouting','smart')
    end

end


