function[hClump,clumpLatency]=utilAddClump(parent,clumpInfo,clumpInfoName,globalInfo,...
    position,clumpNum,numSolverIter,startIter,latencyStrategy)






    if~clumpNum
        name='Differential Clump';
    else
        name=strcat('Algebraic Clump ',int2str(clumpNum));
    end



    doubleType=strcmp(globalInfo.dataType,'double');
    storageDataType=globalInfo.storageDataType;


    hClump=utilAddSubsystem(parent,name,position);
    clumpName=getfullname(hClump);
    lines=cell(0,2);



    hInU=add_block('hdlsllib/Sources/In1',strcat(clumpName,'/U'),...
    'MakeNameUnique','on',...
    'Position',[-165,173,-135,187]);


    hInX=add_block('hdlsllib/Sources/In1',strcat(clumpName,'/State'),...
    'MakeNameUnique','on',...
    'Position',[-165,88,-135,102]);

    hInSel=add_block('hdlsllib/Sources/In1',strcat(clumpName,'/Mode Vector'),...
    'MakeNameUnique','on',...
    'Position',[-165,323,-135,337]);

    hInT=add_block('hdlsllib/Sources/In1',strcat(clumpName,'/t'),...
    'MakeNameUnique','on',...
    'Position',[-165,223,-135,237]);




    hOut=add_block('hdlsllib/Sinks/Out1',strcat(clumpName,'/State Out'),...
    'MakeNameUnique','on',...
    'Position',[960,253,990,267]);

    hModeOut=add_block('hdlsllib/Sinks/Out1',strcat(clumpName,'/Mode Vector Out'),...
    'MakeNameUnique','on',...
    'Position',[960,353,990,367]);

    fModechart=matlab.internal.feature("SSC2HDLModechart");

    if(fModechart&&globalInfo.numQs>0)
        hInQ=add_block('hdlsllib/Sources/In1',strcat(clumpName,'/Q'),...
        'MakeNameUnique','on',...
        'Position',[-205,300,-175,300]);
        hInCI=add_block('hdlsllib/Sources/In1',strcat(clumpName,'/CI'),...
        'MakeNameUnique','on',...
        'Position',[-205,400,-175,400]);
    end







    if numSolverIter>1

        hInCounter=add_block('hdlsllib/Sources/In1',strcat(clumpName,'/Counter'),...
        'MakeNameUnique','on',...
        'Position',[-165,223,-135,237]);


        hXinLoop=utilAddXinLoop(clumpName,[-100,65,15,125],...
        startIter,'State',globalInfo.dataType);
        lines=[lines;{strcat(get_param(hInX,'name'),'/1'),...
        strcat(get_param(hXinLoop,'name'),'/1')}];
        lines=[lines;{strcat(get_param(hInCounter,'name'),'/1'),...
        strcat(get_param(hXinLoop,'name'),'/2')}];

        hXold=hXinLoop;


        if(fModechart&&globalInfo.numQs>0)


            hQinLoop=utilAddXinLoop(clumpName,[200,65,215,125],...
            startIter,'Q',globalInfo.dataType);
            lines=[lines;{strcat(get_param(hInQ,'name'),'/1'),...
            strcat(get_param(hQinLoop,'name'),'/1')}];
            lines=[lines;{strcat(get_param(hInCounter,'name'),'/1'),...
            strcat(get_param(hQinLoop,'name'),'/2')}];

            hQold=hQinLoop;


            hCIinLoop=utilAddXinLoop(clumpName,[400,65,415,125],...
            startIter,'CI',globalInfo.dataType);
            lines=[lines;{strcat(get_param(hInCI,'name'),'/1'),...
            strcat(get_param(hCIinLoop,'name'),'/1')}];
            lines=[lines;{strcat(get_param(hInCounter,'name'),'/1'),...
            strcat(get_param(hCIinLoop,'name'),'/2')}];

            hCIold=hCIinLoop;


        end
    else
        hXold=hInX;
        if(fModechart&&globalInfo.numQs>0)
            hQold=hInQ;
            hCIold=hInCI;
        end
    end












    if~clumpNum
        numStates=globalInfo.numStates;
        numInputs=globalInfo.numInputs;
        numModes=globalInfo.totalModes;
        numQs=globalInfo.numQs;
        numCIs=globalInfo.numCIs;
    else
        numStates=numel(clumpInfo.ReferencedStates);
        numInputs=numel(clumpInfo.ReferencedInputs);
        numModes=numel(clumpInfo.ReferencedModes);
        numQs=numel(clumpInfo.ReferencedQs);
        numCIs=numel(clumpInfo.ReferencedCIs);
    end

    if numInputs<1
        numInputs=1;
    end
    if numModes<1
        numModes=1;
    end

    if(fModechart&&globalInfo.numQs>0&&numQs<1)
        numQs=1;
    end

    if(fModechart&&globalInfo.numQs>0&&numCIs<1)
        numCIs=1;
    end

    if(fModechart&&globalInfo.numQs>0)
        argDims={[numStates,1],...
        [numInputs,1],...
        [1,1],...
        [numModes,1],...
        [1,numQs],...
        [1,numCIs]};
    else

        argDims={[numStates,1],...
        [numInputs,1],...
        [1,1],...
        [numModes,1]};
    end



    [hF,MlBlkInfo]=utilAddML2SLSubsystem(clumpName,clumpInfo.F,[215,165,365,235],...
    globalInfo.dataType,argDims,globalInfo.sampleTime,latencyStrategy,globalInfo.numQs>0);

    clumpMatrixF=clumpInfo.MdInv;
    dataType=storageDataType;
    numInPortsForSumBlk=2;

    dotprodLatencyFun=getMatrixMultiplyLatency(clumpMatrixF,dataType,latencyStrategy);

    addersLatency=getaddersLatency(numInPortsForSumBlk,dataType,latencyStrategy);
    clumpModeSellBlkLatency=0;


    hTranspose=add_block('hdlsllib/HDL Floating Point Operations/Transpose',strcat(clumpName,'/transpose'),...
    'MakeNameUnique','on',...
    'Position',[415,181,455,219]);




    if~clumpNum
        hOwnedStateSelector=add_block('hdlsllib/Signal Routing/Selector',strcat(clumpName,'/Owned States'),...
        'MakeNameUnique','on',...
        'Indices',strcat('[',int2str(clumpInfo.DiffStates'),']'),...
        'InputPortWidth','-1',...
        'Position',[110,76,150,114]);
        hInputDelay=add_block('hdlsllib/Discrete/Delay',strcat(clumpName,'/Input Delay'),...
        'MakeNameUnique','on',...
        'DelayLength','1',...
        'Position',[290,378,325,412]);
        hTimeDelay=add_block('hdlsllib/Discrete/Delay',strcat(clumpName,'/t Delay'),...
        'MakeNameUnique','on',...
        'DelayLength','1',...
        'Position',[290,378,325,412]);

    else
        hOwnedStateSelector=add_block('hdlsllib/Signal Routing/Selector',strcat(clumpName,'/Owned States'),...
        'MakeNameUnique','on',...
        'Indices',strcat('[',int2str(clumpInfo.OwnedStates'),']'),...
        'InputPortWidth','-1',...
        'Position',[260,76,300,114]);
        hRefStateSelector=add_block('hdlsllib/Signal Routing/Selector',strcat(clumpName,'/Ref States'),...
        'MakeNameUnique','on',...
        'Indices',strcat('[',int2str(clumpInfo.ReferencedStates'),']'),...
        'InputPortWidth','-1',...
        'Position',[110,76,150,114]);
        if isempty(clumpInfo.ReferencedInputs)
            clumpInfo.ReferencedInputs=1;
        end
        hInputSelector=add_block('hdlsllib/Signal Routing/Selector',strcat(clumpName,'/Ref Inputs'),...
        'MakeNameUnique','on',...
        'Indices',strcat('[',int2str(clumpInfo.ReferencedInputs'),']'),...
        'InputPortWidth','-1',...
        'Position',[110,161,150,199]);
        hModeSelector=add_block('hdlsllib/Signal Routing/Selector',strcat(clumpName,'/Ref Modes'),...
        'MakeNameUnique','on',...
        'Indices',strcat('[',int2str(clumpInfo.ReferencedModes'),']'),...
        'InputPortWidth','-1',...
        'Position',[110,161,150,199]);
        if(fModechart&&globalInfo.numQs>0)

            if isempty(clumpInfo.ReferencedQs)
                clumpInfo.ReferencedQs=1;
            end
            if isempty(clumpInfo.ReferencedCIs)
                clumpInfo.ReferencedCIs=1;
            end
            hQSelector=add_block('hdlsllib/Signal Routing/Selector',strcat(clumpName,'/Ref Qs'),...
            'MakeNameUnique','on',...
            'Indices',strcat('[',int2str(clumpInfo.ReferencedQs'),']'),...
            'InputPortWidth','-1',...
            'Position',[110,161,150,199]);
            hCISelector=add_block('hdlsllib/Signal Routing/Selector',strcat(clumpName,'/Ref CIs'),...
            'MakeNameUnique','on',...
            'Indices',strcat('[',int2str(clumpInfo.ReferencedCIs'),']'),...
            'InputPortWidth','-1',...
            'Position',[110,161,150,199]);
        end
    end

    if~clumpNum
        indexArray=strcat('[',num2str(clumpInfo.DiffStates'),']');
    else
        indexArray=strcat('[',num2str(clumpInfo.ReferencedStates(clumpInfo.OwnedStates(find(clumpInfo.OutFlags)))'),']');
    end


    if globalInfo.numStates>1
        hAssign=add_block('hdlsllib/Math Operations/Assignment',strcat(clumpName,'/State Assign'),...
        'MakeNameUnique','on',...
        'Position',[850,241,920,274],...
        'IndexParamArray',{indexArray});

    else
        hAssign=[];
    end



    hsumBlk=add_block('hdlsllib/HDL Floating Point Operations/Add',strcat(clumpName,'/Output Sum'),...
    'MakeNameUnique','on',...
    'Position',[635,168,665,212],...
    'Inputs','+-');


    if~isempty(clumpInfo.MatrixModes)||(fModechart&&~isempty(clumpInfo.MatrixQs))





        if(numel(clumpInfo.MatrixModes)>0)
            matrixModes=clumpInfo.MatrixModes;
        else
            matrixModes=[1];
        end

        if logical(clumpNum)
            if~isempty(clumpInfo.ModeFcn)

                [hModeSel,ModeSellBlkInfo]=utilAddModeSelectionLogic(clumpName,clumpInfo,...
                [-25,247,85,343],numSolverIter,globalInfo.dataType,globalInfo,latencyStrategy);



                clumpModeSellBlkLatency=ModeSellBlkInfo.mlfbBlkLatency;
                if numSolverIter>1
                    hStateDelay=add_block('hdlsllib/Discrete/Delay',strcat(clumpName,'/Delay'),...
                    'MakeNameUnique','on',...
                    'DelayLength','1',...
                    'Orientation','left',...
                    'Position',[290,378,325,412]);

                    hRefStatesSel2=add_block('hdlsllib/Signal Routing/Selector',strcat(clumpName,'/Ref States'),...
                    'MakeNameUnique','on',...
                    'Indices',strcat('[',int2str(clumpInfo.ReferencedStates'),']'),...
                    'Orientation','left',...
                    'InputPortWidth','-1',...
                    'Position',[390,376,430,414]);
                end
                modeToSelPort=strcat(get_param(hModeSel,'name'),'/2');


                lines=[lines;{strcat(get_param(hInputSelector,'name'),'/1'),...
                strcat(get_param(hModeSel,'name'),'/1')}];

                lines=[lines;{strcat(get_param(hRefStateSelector,'name'),'/1'),...
                strcat(get_param(hModeSel,'name'),'/2')}];

                lines=[lines;{strcat(get_param(hInSel,'name'),'/1'),...
                strcat(get_param(hModeSel,'name'),'/3')}];

                lines=[lines;{strcat(get_param(hInT,'name'),'/1'),...
                strcat(get_param(hModeSel,'name'),'/4')}];

                if(fModechart&&globalInfo.numQs>0)

                    lines=[lines;{strcat(get_param(hQSelector,'name'),'/1'),...
                    strcat(get_param(hModeSel,'name'),'/5')}];

                    lines=[lines;{strcat(get_param(hCISelector,'name'),'/1'),...
                    strcat(get_param(hModeSel,'name'),'/6')}];

                end

                if numSolverIter>1

                    portOffset=0;
                    if(fModechart&&globalInfo.numQs>0)
                        portOffset=2;
                    end

                    lines=[lines;{strcat(get_param(hStateDelay,'name'),'/1'),...
                    strcat(get_param(hModeSel,'name'),['/',int2str(5+portOffset)])}];

                    lines=[lines;{strcat(get_param(hInCounter,'name'),'/1'),...
                    strcat(get_param(hModeSel,'name'),['/',int2str(6+portOffset)])}];

                    lines=[lines;{strcat(get_param(hRefStatesSel2,'name'),'/1'),...
                    strcat(get_param(hStateDelay,'name'),'/1')}];

                    if globalInfo.numStates>1
                        lines=[lines;{strcat(get_param(hAssign,'name'),'/1'),...
                        strcat(get_param(hRefStatesSel2,'name'),'/1')}];
                    else
                        lines=[lines;{strcat(get_param(hsumBlk,'name'),'/1'),...
                        strcat(get_param(hRefStatesSel2,'name'),'/1')}];
                    end

                end

                lines=[lines;{strcat(get_param(hModeSel,'name'),'/2'),...
                strcat(get_param(hModeOut,'name'),'/1')}];

            else

                hModeSel=add_block('hdlsllib/Signal Routing/Selector',strcat(clumpName,'/Selector'),...
                'MakeNameUnique','on',...
                'Indices',strcat('[',int2str(clumpInfo.ReferencedModes(matrixModes)'),']'),...
                'InputPortWidth','-1',...
                'Position',[110,266,150,304]);
                lines=[lines;{strcat(get_param(hInSel,'name'),'/1'),...
                strcat(get_param(hModeSel,'name'),'/1')}];

                lines=[lines;{strcat(get_param(hInSel,'name'),'/1'),...
                strcat(get_param(hModeOut,'name'),'/1')}];
                modeToSelPort=strcat(get_param(hInSel,'name'),'/1');
            end
        else

            hModeSel=add_block('hdlsllib/Signal Routing/Selector',strcat(clumpName,'/Selector'),...
            'MakeNameUnique','on',...
            'Indices',strcat('[',int2str((matrixModes)'),']'),...
            'InputPortWidth','-1',...
            'Position',[110,266,150,304]);
            lines=[lines;{strcat(get_param(hInSel,'name'),'/1'),...
            strcat(get_param(hModeSel,'name'),'/1')}];

            lines=[lines;{strcat(get_param(hInSel,'name'),'/1'),...
            strcat(get_param(hModeOut,'name'),'/1')}];
            modeToSelPort=strcat(get_param(hInSel,'name'),'/1');
        end




        featIntModes=matlab.internal.feature("SSC2HDLIntegerModes");
        if(featIntModes)


            localIntModeInds=[];
            for i=globalInfo.IntModes'
                if~clumpNum
                    localIntModeInds=[localIntModeInds,find(clumpInfo.MatrixModes'==i)];
                else
                    localIntModeInds=[localIntModeInds,find(clumpInfo.ReferencedModes(clumpInfo.MatrixModes)'==i)];
                end
            end


            modeVecBin=utilModeVecToBool(clumpInfo.ModeVec,localIntModeInds);

            if(fModechart&&globalInfo.numQs>0)

                qVecBin=utilModeVecToBool(clumpInfo.QVec,1:size(clumpInfo.QVec,1));
            end


            if(fModechart&&globalInfo.numQs>0)
                fullModeVec=[modeVecBin;qVecBin];
            else
                fullModeVec=modeVecBin;
            end

            if strcmp(hdlfeature('SSCHDLLogicTable'),'on')
                hModeToVec=utilLogicFunction(clumpName,fullModeVec,[250,266,310,304],globalInfo.sampleTime,globalInfo);
            else

                hModeToVec=utilAddModeVec2Ind(clumpName,fullModeVec,[250,266,310,304],globalInfo.sampleTime,globalInfo);
            end
            hNFPINSrc=hModeToVec;

            if(fModechart&&globalInfo.numQs>0)

                hModeTypeConversion=utilAddModeVecTypeConversion(clumpName,clumpInfo.ModeVec,clumpInfo.QVec,[200,266,260,304],localIntModeInds,globalInfo);
            else

                hModeTypeConversion=utilAddModeVecTypeConversion(clumpName,clumpInfo.ModeVec,[],[200,266,260,304],localIntModeInds,globalInfo);

            end

            lines=[lines;{strcat(get_param(hModeTypeConversion,'name'),'/1'),...
            strcat(get_param(hModeToVec,'name'),'/1')}];



            lines=[lines;{strcat(get_param(hModeSel,'name'),'/1'),...
            strcat(get_param(hModeTypeConversion,'name'),'/1')}];


            if(fModechart&&globalInfo.numQs>0)

                if isempty(clumpInfo.MatrixQs)
                    clumpInfo.MatrixQs=1;
                end

                if(logical(clumpNum))
                    matrixQInds=clumpInfo.ReferencedQs(clumpInfo.MatrixQs);
                else
                    matrixQInds=clumpInfo.MatrixQs;
                end

                hMatrixQs=add_block('hdlsllib/Signal Routing/Selector',strcat(clumpName,'/Matrix Qs'),...
                'MakeNameUnique','on',...
                'Indices',strcat('[',int2str(matrixQInds'),']'),...
                'InputPortWidth','-1',...
                'Position',[110,161,150,199]);

                lines=[lines;{strcat(get_param(hQold,'name'),'/1'),...
                strcat(get_param(hMatrixQs,'name'),'/1')}];

                lines=[lines;{strcat(get_param(hMatrixQs,'name'),'/1'),...
                strcat(get_param(hModeTypeConversion,'name'),'/2')}];

            end
        else
            if strcmp(hdlfeature('SSCHDLLogicTable'),'on')
                hModeToVec=utilLogicFunction(clumpName,clumpInfo.ModeVec,[250,266,310,304],globalInfo.sampleTime,globalInfo);
            else

                hModeToVec=utilAddModeVec2Ind(clumpName,clumpInfo.ModeVec,[250,266,310,304],globalInfo.sampleTime,globalInfo);
            end
            hNFPINSrc=hModeToVec;
            lines=[lines;{strcat(get_param(hModeSel,'name'),'/1'),...
            strcat(get_param(hModeToVec,'name'),'/1')}];
        end
    else
        hConst=add_block('hdlsllib/Sources/Constant',strcat(clumpName,'/Default Index'),...
        'MakeNameUnique','on',...
        'Value','fi(0,0,2,0)',...
        'SampleTime',compactButAccurateNum2Str(globalInfo.sampleTime),...
        'Position',[250,266,310,304]);

        hNFPINSrc=hConst;
        modeToSelPort=strcat(get_param(hInSel,'name'),'/1');

        lines=[lines;{strcat(get_param(hInSel,'name'),'/1'),...
        strcat(get_param(hModeOut,'name'),'/1')}];
    end

    hmultiplyBlk1=add_block('hdlssclib/NFPSparseConstMultiply',strcat(clumpName,'/Multiply F'),...
    'MakeNameUnique','on',...
    'Position',[515,75,595,155],...
    'constMatrix',strcat(globalInfo.storageDataType,'(',clumpInfoName.MdInv,')'));


    if clumpNum
        hmultiplyBlk2=add_block('hdlssclib/NFPSparseConstMultiply',strcat(clumpName,'/Multiply State'),...
        'MakeNameUnique','on',...
        'Position',[730,225,810,305],...
        'constMatrix',strcat(globalInfo.storageDataType,'(',clumpInfoName.Ad,')'));
    end





    if~clumpNum
        lines=[lines;{strcat(get_param(hInU,'name'),'/1'),...
        strcat(get_param(hInputDelay,'name'),'/1')}];


        lines=[lines;{strcat(get_param(hInputDelay,'name'),'/1'),...
        strcat(get_param(hF,'name'),'/2')}];

        lines=[lines;{strcat(get_param(hXold,'name'),'/1'),...
        strcat(get_param(hF,'name'),'/1')}];

        lines=[lines;{strcat(get_param(hTimeDelay,'name'),'/1'),...
        strcat(get_param(hF,'name'),'/3')}];

        lines=[lines;{modeToSelPort,...
        strcat(get_param(hF,'name'),'/4')}];

        if(fModechart&&globalInfo.numQs>0)
            lines=[lines;{strcat(get_param(hQold,'name'),'/1'),...
            strcat(get_param(hF,'name'),'/5')}];

            lines=[lines;{strcat(get_param(hCIold,'name'),'/1'),...
            strcat(get_param(hF,'name'),'/6')}];
        end

        lines=[lines;{strcat(get_param(hXold,'name'),'/1'),...
        strcat(get_param(hOwnedStateSelector,'name'),'/1')}];

        if globalInfo.numStates>1

            lines=[lines;{strcat(get_param(hXold,'name'),'/1'),...
            strcat(get_param(hAssign,'name'),'/1')}];
        end
        lines=[lines;{strcat(get_param(hNFPINSrc,'name'),'/1'),...
        strcat(get_param(hmultiplyBlk1,'name'),'/2')}];

        lines=[lines;{strcat(get_param(hInT,'name'),'/1'),...
        strcat(get_param(hTimeDelay,'name'),'/1')}];




        lines=[lines;{strcat(get_param(hF,'name'),'/1'),...
        strcat(get_param(hTranspose,'name'),'/1')}];



        lines=[lines;{strcat(get_param(hTranspose,'name'),'/1'),...
        strcat(get_param(hmultiplyBlk1,'name'),'/1')}];


        lines=[lines;{strcat(get_param(hmultiplyBlk1,'name'),'/1'),...
        strcat(get_param(hsumBlk,'name'),'/2')}];

        lines=[lines;{strcat(get_param(hOwnedStateSelector,'name'),'/1'),...
        strcat(get_param(hsumBlk,'name'),'/1')}];
        if globalInfo.numStates>1
            lines=[lines;{strcat(get_param(hsumBlk,'name'),'/1'),...
            strcat(get_param(hAssign,'name'),'/2')}];

            lines=[lines;{strcat(get_param(hAssign,'name'),'/1'),...
            strcat(get_param(hOut,'name'),'/1')}];
        else
            lines=[lines;{strcat(get_param(hsumBlk,'name'),'/1'),...
            strcat(get_param(hOut,'name'),'/1')}];
        end


    else
        lines=[lines;{strcat(get_param(hInU,'name'),'/1'),...
        strcat(get_param(hInputSelector,'name'),'/1')}];


        lines=[lines;{strcat(get_param(hInputSelector,'name'),'/1'),...
        strcat(get_param(hF,'name'),'/2')}];


        lines=[lines;{strcat(get_param(hRefStateSelector,'name'),'/1'),...
        strcat(get_param(hF,'name'),'/1')}];

        lines=[lines;{strcat(get_param(hInT,'name'),'/1'),...
        strcat(get_param(hF,'name'),'/3')}];


        lines=[lines;{strcat(get_param(hModeSelector,'name'),'/1'),...
        strcat(get_param(hF,'name'),'/4')}];
        if(fModechart&&globalInfo.numQs>0)

            lines=[lines;{strcat(get_param(hQold,'name'),'/1'),...
            strcat(get_param(hQSelector,'name'),'/1')}];

            lines=[lines;{strcat(get_param(hCIold,'name'),'/1'),...
            strcat(get_param(hCISelector,'name'),'/1')}];
            lines=[lines;{strcat(get_param(hQSelector,'name'),'/1'),...
            strcat(get_param(hF,'name'),'/5')}];

            lines=[lines;{strcat(get_param(hCISelector,'name'),'/1'),...
            strcat(get_param(hF,'name'),'/6')}];
        end

        lines=[lines;{strcat(get_param(hXold,'name'),'/1'),...
        strcat(get_param(hRefStateSelector,'name'),'/1')}];

        lines=[lines;{strcat(get_param(hRefStateSelector,'name'),'/1'),...
        strcat(get_param(hOwnedStateSelector,'name'),'/1')}];


        lines=[lines;{modeToSelPort,...
        strcat(get_param(hModeSelector,'name'),'/1')}];

        if globalInfo.numStates>1

            lines=[lines;{strcat(get_param(hXold,'name'),'/1'),...
            strcat(get_param(hAssign,'name'),'/1')}];
        end
        lines=[lines;{strcat(get_param(hNFPINSrc,'name'),'/1'),...
        strcat(get_param(hmultiplyBlk2,'name'),'/2')}];

        lines=[lines;{strcat(get_param(hNFPINSrc,'name'),'/1'),...
        strcat(get_param(hmultiplyBlk1,'name'),'/2')}];



        lines=[lines;{strcat(get_param(hF,'name'),'/1'),...
        strcat(get_param(hTranspose,'name'),'/1')}];




        lines=[lines;{strcat(get_param(hTranspose,'name'),'/1'),...
        strcat(get_param(hmultiplyBlk1,'name'),'/1')}];

        lines=[lines;{strcat(get_param(hmultiplyBlk1,'name'),'/1'),...
        strcat(get_param(hsumBlk,'name'),'/2')}];

        lines=[lines;{strcat(get_param(hOwnedStateSelector,'name'),'/1'),...
        strcat(get_param(hmultiplyBlk2,'name'),'/1')}];

        lines=[lines;{strcat(get_param(hmultiplyBlk2,'name'),'/1'),...
        strcat(get_param(hsumBlk,'name'),'/1')}];
        if globalInfo.numStates>1


            hOutStateSelector=add_block('hdlsllib/Signal Routing/Selector',strcat(clumpName,'/Out States'),...
            'MakeNameUnique','on',...
            'Indices',strcat('[',int2str(find(clumpInfo.OutFlags)'),']'),...
            'InputPortWidth','-1',...
            'Position',[675,222,700,242]);

            lines=[lines;{strcat(get_param(hsumBlk,'name'),'/1'),...
            strcat(get_param(hOutStateSelector,'name'),'/1')}];

            lines=[lines;{strcat(get_param(hOutStateSelector,'name'),'/1'),...
            strcat(get_param(hAssign,'name'),'/2')}];

            lines=[lines;{strcat(get_param(hAssign,'name'),'/1'),...
            strcat(get_param(hOut,'name'),'/1')}];
        else
            lines=[lines;{strcat(get_param(hsumBlk,'name'),'/1'),...
            strcat(get_param(hOut,'name'),'/1')}];

        end

    end


    add_line(clumpName,lines(:,1),lines(:,2),'AutoRouting','smart')
    Simulink.BlockDiagram.arrangeSystem(clumpName,'FullLayout','True','Animation','False');

    clumpMLFBLatency=MlBlkInfo.mlfbBlkLatency;



    clumpLatency=clumpMLFBLatency+clumpModeSellBlkLatency+dotprodLatencyFun+addersLatency;



end
function dotprodLatencyFun=getMatrixMultiplyLatency(constMatrix,dataType,latencyStrategy)


    [~,activeRowPositions,~]=sschdloptimizations.getActiveElements(constMatrix,1);



    maxRowElements=0;
    for ii=1:numel(activeRowPositions)
        rowElements=activeRowPositions{ii};
        if(numel(rowElements)>maxRowElements)
            maxRowElements=numel(rowElements);
        end
    end


    maxAdderTreeStages=0;
    if(maxRowElements>0)
        maxAdderTreeStages=ceil(log2(maxRowElements));
    end


    [minval,maxval]=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies('Mul',dataType,'NATIVEFLOATINGPOINT');
    if strcmpi(latencyStrategy,'MIN')
        mulLatency=minval;
    elseif strcmpi(latencyStrategy,'MAX')
        mulLatency=maxval;
    else
        mulLatency=0;
    end

    [minval,maxval]=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies('ADDSUB',dataType,'NATIVEFLOATINGPOINT');
    if strcmpi(latencyStrategy,'MIN')
        addLatency=minval;
    elseif strcmpi(latencyStrategy,'MAX')
        addLatency=maxval;
    else
        addLatency=0;
    end



    dotprodLatencyFun=double(mulLatency+maxAdderTreeStages*addLatency);

end



function addersLatency=getaddersLatency(numOfInPorts,dataType,latencyStrategy)

    addCompsCount=numOfInPorts-1;

    [minval,maxval]=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies('ADDSUB',dataType,'NATIVEFLOATINGPOINT');
    if strcmpi(latencyStrategy,'MIN')
        addLatency=minval;
    elseif strcmpi(latencyStrategy,'MAX')
        addLatency=maxval;
    else
        addLatency=0;
    end
    addersLatency=0;
    if addCompsCount>0
        addersLatency=addLatency*addCompsCount;
    end
end


