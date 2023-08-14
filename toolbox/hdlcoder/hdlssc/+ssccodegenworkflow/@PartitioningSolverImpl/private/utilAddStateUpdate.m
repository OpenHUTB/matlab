function[hStateUpdate,stateUpdateLatency]=utilAddStateUpdate(parent,EqnData,EqnName,position,latencyStrategy)
    dataType=EqnData.GlobalData.dataType;





    hStateUpdate=utilAddSubsystem(parent,'State Update',position);
    StateUpdateName=getfullname(hStateUpdate);


    hInU=add_block('hdlsllib/Sources/In1',strcat(StateUpdateName,'/U'),...
    'MakeNameUnique','on',...
    'Position',[-205,-57,-175,-43]);
    hInT=add_block('hdlsllib/Sources/In1',strcat(StateUpdateName,'/t'),...
    'MakeNameUnique','on',...
    'Position',[-205,248,-175,262]);

    hOut=add_block('hdlsllib/Sinks/Out1',strcat(StateUpdateName,'/State'),...
    'MakeNameUnique','on',...
    'Position',[1110,-28,1150,-12]);
    hModeOut=add_block('hdlsllib/Sinks/Out1',strcat(StateUpdateName,'/Mode'),...
    'MakeNameUnique','on',...
    'Position',[1110,-28,1150,-12]);

    fModechart=matlab.internal.feature("SSC2HDLModechart");

    if(fModechart&&EqnData.GlobalData.numQs>0)
        hInQ=add_block('hdlsllib/Sources/In1',strcat(StateUpdateName,'/Q'),...
        'MakeNameUnique','on',...
        'Position',[-205,300,-175,315]);
        hInCI=add_block('hdlsllib/Sources/In1',strcat(StateUpdateName,'/CI'),...
        'MakeNameUnique','on',...
        'Position',[-205,400,-175,415]);

        hQOut=add_block('hdlsllib/Sinks/Out1',strcat(StateUpdateName,'/Q Out'),...
        'MakeNameUnique','on',...
        'Position',[1110,-28,1150,-12]);
        hCIOut=add_block('hdlsllib/Sinks/Out1',strcat(StateUpdateName,'/CI Out'),...
        'MakeNameUnique','on',...
        'Position',[1110,-28,1150,-12]);
        hOut2=add_block('hdlsllib/Sinks/Out1',strcat(StateUpdateName,'/Next State'),...
        'MakeNameUnique','on',...
        'Position',[1110,-28,1150,-12]);
        hModeOut2=add_block('hdlsllib/Sinks/Out1',strcat(StateUpdateName,'/Next Mode'),...
        'MakeNameUnique','on',...
        'Position',[1110,-28,1150,-12]);
    end

    if EqnData.GlobalData.TotalIters>1
        hInCounter=add_block('hdlsllib/Sources/In1',strcat(StateUpdateName,'/Counter'),...
        'MakeNameUnique','on',...
        'Position',[-205,248,-175,262]);
    end

    hGlobalMF=[];
    hAssigner=[];
    hModeDTC=[];
    globalModeFunLatency=0;

    if~isempty(EqnData.GlobalModeFcn)

        numStates=EqnData.GlobalData.numStates;
        numInputs=EqnData.GlobalData.numInputs;
        numQs=EqnData.GlobalData.numQs;
        numCIs=EqnData.GlobalData.numCIs;

        if numInputs<1
            numInputs=1;
        end

        if(fModechart&&numQs>0)
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

        [hGlobalMF,globalModeFunInfo]=utilAddML2SLSubsystem(StateUpdateName,EqnData.GlobalModeFcn,...
        [45,161,180,229],dataType,argDims,EqnData.GlobalData.sampleTime,latencyStrategy,numQs>0);
        globalModeFunLatency=globalModeFunInfo.mlfbBlkLatency;
        if(numel(EqnData.IM)>1)
            hAssigner=add_block('hdlsllib/Math Operations/Assignment',strcat(StateUpdateName,'/Mode Assignment'),...
            'MakeNameUnique','on',...
            'IndexParamArray',{strcat('[',int2str(EqnData.ModeIndices'),']')},...
            'Position',[220,176,260,214]);
        end

        featIntModes=matlab.internal.feature('SSC2HDLIntegerModes');

        if(featIntModes)


            dtc=Simulink.findBlocksOfType(hGlobalMF,'DataTypeConversion');

            for i=1:length(dtc)
                set_param(getfullname(dtc(i)),'SaturateOnIntegerOverflow','off');
            end

            hModeDTC=add_block('hdlsllib/Signal Attributes/Data Type Conversion',strcat(StateUpdateName,'/Data Type Conversion'),...
            'MakeNameUnique','on',...
            'Position',[220,176,260,214],...
            'OutDataTypeStr','int32',...
            'RndMeth','Nearest');
        end

    end


    hICsystem=utilAddICsystem(StateUpdateName,[85,83,180,147],...
    EqnName,EqnData.GlobalData,dataType);




    hDiffClump=[];
    clumpNum=0;
    startIter=0;
    iterNum=1;
    diffClumpLatency=0;
    if~isempty(EqnData.DiffClumpInfo.DiffStates)
        [hDiffClump,diffClumpLatency]=utilAddClump(StateUpdateName,EqnData.DiffClumpInfo,...
        EqnName.DiffClumpInfo,EqnData.GlobalData,[-80,-38,10,63],...
        clumpNum,iterNum,startIter,latencyStrategy);
    end





    hClump=zeros(1,numel(EqnData.ClumpInfo));
    clumpPos=[330,-18,475,68];
    clumpLatency=zeros(1,numel(EqnData.ClumpInfo));
    for clumpNum=1:numel(EqnData.ClumpInfo)
        if~isempty(EqnData.ClumpInfo(clumpNum).ModeFcn)
            iterNum=EqnData.GlobalData.NumSolverIter;
        else
            iterNum=1;
        end


        [hClump(clumpNum),clumpLatency(clumpNum)]=utilAddClump(StateUpdateName,EqnData.ClumpInfo(clumpNum),...
        EqnName.ClumpInfo(clumpNum),EqnData.GlobalData,clumpPos,clumpNum,...
        iterNum,startIter,latencyStrategy);

        clumpPos=clumpPos+[195,10,195,10];
        startIter=startIter+(iterNum-1);

        if iterNum>1
            port=5;
            if(fModechart&&EqnData.GlobalData.numQs>0)
                port=7;
            end
            add_line(StateUpdateName,strcat(get_param(hInCounter,'name'),'/1'),...
            strcat(get_param(hClump(clumpNum),'name'),['/',int2str(port)]),'AutoRouting','smart')
        end
    end


    [lineSrc,lineDst]=wireStateUpdate(hDiffClump,hClump,hInU,hInT,hOut,...
    hModeOut,hGlobalMF,hAssigner,hModeDTC,hICsystem,StateUpdateName);

    add_line(StateUpdateName,lineSrc,lineDst,'AutoRouting','smart')

    if(fModechart&&EqnData.GlobalData.numQs>0)
        [lineSrc,lineDst]=wireQVec(hDiffClump,hClump,hInQ,hInCI,hQOut,hCIOut,hOut2,hModeOut2,hGlobalMF,hICsystem,hModeDTC);
        add_line(StateUpdateName,lineSrc,lineDst,'AutoRouting','smart')
    end




    if numel(EqnData.ClumpInfo)==0&&isempty(EqnData.GlobalModeFcn)...
        &&isempty(EqnData.DiffClumpInfo.DiffStates)

        hUTerm=add_block('hdlsllib/Sinks/Terminator',strcat(StateUpdateName,'/Valid Out'),...
        'MakeNameUnique','on');
        hTTerm=add_block('hdlsllib/Sinks/Terminator',strcat(StateUpdateName,'/Valid Out'),...
        'MakeNameUnique','on');
        add_line(StateUpdateName,strcat(get_param(hInU,'name'),'/1'),...
        strcat(get_param(hUTerm,'name'),'/1'),'AutoRouting','on')
        add_line(StateUpdateName,strcat(get_param(hInT,'name'),'/1'),...
        strcat(get_param(hTTerm,'name'),'/1'),'AutoRouting','on')

    end



    Simulink.BlockDiagram.arrangeSystem(StateUpdateName,'FullLayout','True','Animation','False');


    stateUpdateLatency=diffClumpLatency+sum(clumpLatency(:));


    if(stateUpdateLatency==0)
        stateUpdateLatency=1;
    end


end

function[lineSrc,lineDst]=wireStateUpdate(hDiffClump,hClump,hInU,hInT,hOut,hModeOut,hGlobalMF,...
    hAssigner,hModeDTC,hICsystem,StateUpdateName)



    lineCounter=1;
    if~isempty(hGlobalMF)&&~numel(hClump)&&isempty(hAssigner)
        hTiTerm=add_block('hdlsllib/Sinks/Terminator',strcat(StateUpdateName,'/Terminator'),...
        'MakeNameUnique','on');
    else
        hTiTerm=[];
    end

    fModechart=matlab.internal.feature("SSC2HDLModechart");
    fIntModes=matlab.internal.feature("SSC2HDLIntegerModes");


    if(~fIntModes&&~isempty(hGlobalMF))
        globalModeSource=hGlobalMF;
    elseif~isempty(hGlobalMF)
        globalModeSource=hModeDTC;



        lineDst{lineCounter}=strcat(get_param(hModeDTC,'name'),'/1');
        lineSrc{lineCounter}=strcat(get_param(hGlobalMF,'name'),'/1');
        lineCounter=lineCounter+1;
    end



    if~isempty(hDiffClump)

        lineDst{lineCounter}=strcat(get_param(hDiffClump,'name'),'/1');
        lineSrc{lineCounter}=strcat(get_param(hInU,'name'),'/1');
        lineCounter=lineCounter+1;

        lineDst{lineCounter}=strcat(get_param(hDiffClump,'name'),'/2');
        lineSrc{lineCounter}=strcat(get_param(hICsystem,'name'),'/1');
        lineCounter=lineCounter+1;

        lineDst{lineCounter}=strcat(get_param(hDiffClump,'name'),'/3');
        lineSrc{lineCounter}=strcat(get_param(hICsystem,'name'),'/2');
        lineCounter=lineCounter+1;

        lineDst{lineCounter}=strcat(get_param(hDiffClump,'name'),'/4');
        lineSrc{lineCounter}=strcat(get_param(hInT,'name'),'/1');
        lineCounter=lineCounter+1;

    end


    if~isempty(hDiffClump)
        hStateSource=hDiffClump;
        hModeSource=hDiffClump;
    else
        hStateSource=hICsystem;
        hModeSource=hICsystem;

    end
    if~isempty(hGlobalMF)

        lineDst{lineCounter}=strcat(get_param(hGlobalMF,'name'),'/1');
        lineSrc{lineCounter}=strcat(get_param(hStateSource,'name'),'/1');
        lineCounter=lineCounter+1;


        lineDst{lineCounter}=strcat(get_param(hGlobalMF,'name'),'/2');
        lineSrc{lineCounter}=strcat(get_param(hInU,'name'),'/1');
        lineCounter=lineCounter+1;

        lineDst{lineCounter}=strcat(get_param(hGlobalMF,'name'),'/3');
        lineSrc{lineCounter}=strcat(get_param(hInT,'name'),'/1');
        lineCounter=lineCounter+1;
    end


    for i=1:numel(hClump)

        lineDst{lineCounter}=strcat(get_param(hClump(i),'name'),'/1');
        lineSrc{lineCounter}=strcat(get_param(hInU,'name'),'/1');
        lineCounter=lineCounter+1;


        lineDst{lineCounter}=strcat(get_param(hClump(i),'name'),'/2');
        lineSrc{lineCounter}=strcat(get_param(hStateSource,'name'),'/1');
        lineCounter=lineCounter+1;
        hStateSource=hClump(i);
        if i==1

            if~isempty(hAssigner)

                lineDst{lineCounter}=strcat(get_param(hClump(i),'name'),'/3');
                lineSrc{lineCounter}=strcat(get_param(hAssigner,'name'),'/1');
                lineCounter=lineCounter+1;
            else
                lineDst{lineCounter}=strcat(get_param(hClump(i),'name'),'/3');
                if~isempty(hGlobalMF)
                    lineSrc{lineCounter}=strcat(get_param(globalModeSource,'name'),'/1');
                    lineCounter=lineCounter+1;
                else
                    lineSrc{lineCounter}=strcat(get_param(hModeSource,'name'),'/2');
                    lineCounter=lineCounter+1;
                end

            end
        else
            lineDst{lineCounter}=strcat(get_param(hClump(i),'name'),'/3');
            lineSrc{lineCounter}=strcat(get_param(hClump(i-1),'name'),'/2');
            lineCounter=lineCounter+1;
        end


        lineDst{lineCounter}=strcat(get_param(hClump(i),'name'),'/4');
        lineSrc{lineCounter}=strcat(get_param(hInT,'name'),'/1');
        lineCounter=lineCounter+1;


    end


    if numel(hClump)>0


        lineDst{lineCounter}=strcat(get_param(hICsystem,'name'),'/1');
        lineSrc{lineCounter}=strcat(get_param(hClump(numel(hClump)),'name'),'/1');
        lineCounter=lineCounter+1;


        lineDst{lineCounter}=strcat(get_param(hICsystem,'name'),'/2');
        lineSrc{lineCounter}=strcat(get_param(hClump(numel(hClump)),'name'),'/2');
        lineCounter=lineCounter+1;
    elseif~isempty(hDiffClump)



        lineDst{lineCounter}=strcat(get_param(hICsystem,'name'),'/1');
        lineSrc{lineCounter}=strcat(get_param(hDiffClump,'name'),'/1');
        lineCounter=lineCounter+1;




        if~isempty(hAssigner)

            lineDst{lineCounter}=strcat(get_param(hICsystem,'name'),'/2');
            lineSrc{lineCounter}=strcat(get_param(hAssigner,'name'),'/1');
            lineCounter=lineCounter+1;
        else

            if~isempty(hGlobalMF)&&~numel(hClump)&&~isempty(hTiTerm)
                lineDst{lineCounter}=strcat(get_param(hICsystem,'name'),'/2');
                lineSrc{lineCounter}=strcat(get_param(globalModeSource,'name'),'/1');
                lineCounter=lineCounter+1;

                lineSrc{lineCounter}=strcat(get_param(hDiffClump,'name'),'/2');
                lineDst{lineCounter}=strcat(get_param(hTiTerm,'name'),'/1');
                lineCounter=lineCounter+1;
            else
                lineDst{lineCounter}=strcat(get_param(hICsystem,'name'),'/2');
                lineSrc{lineCounter}=strcat(get_param(hDiffClump,'name'),'/2');
                lineCounter=lineCounter+1;
            end
        end
    else


        lineDst{lineCounter}=strcat(get_param(hICsystem,'name'),'/1');
        lineSrc{lineCounter}=strcat(get_param(hICsystem,'name'),'/1');
        lineCounter=lineCounter+1;

        if~isempty(hAssigner)
            lineDst{lineCounter}=strcat(get_param(hICsystem,'name'),'/2');
            lineSrc{lineCounter}=strcat(get_param(hAssigner,'name'),'/1');
            lineCounter=lineCounter+1;
        else


            lineDst{lineCounter}=strcat(get_param(hICsystem,'name'),'/2');
            lineSrc{lineCounter}=strcat(get_param(hICsystem,'name'),'/2');
            lineCounter=lineCounter+1;
        end

    end

    if~isempty(hAssigner)


        featIntModes=matlab.internal.feature('SSC2HDLIntegerModes');
        if(featIntModes)
            lineDst{lineCounter}=strcat(get_param(hAssigner,'name'),'/2');
            lineSrc{lineCounter}=strcat(get_param(hModeDTC,'name'),'/1');
        else
            lineDst{lineCounter}=strcat(get_param(hAssigner,'name'),'/2');
            lineSrc{lineCounter}=strcat(get_param(hGlobalMF,'name'),'/1');
        end

        lineCounter=lineCounter+1;

        lineDst{lineCounter}=strcat(get_param(hAssigner,'name'),'/1');
        lineSrc{lineCounter}=strcat(get_param(hModeSource,'name'),'/2');
        lineCounter=lineCounter+1;

    end




    lineDst{lineCounter}=strcat(get_param(hOut,'name'),'/1');
    lineSrc{lineCounter}=strcat(get_param(hICsystem,'name'),'/1');

    lineCounter=lineCounter+1;

    lineDst{lineCounter}=strcat(get_param(hModeOut,'name'),'/1');
    lineSrc{lineCounter}=strcat(get_param(hICsystem,'name'),'/2');

end


function[lineSrc,lineDst]=wireQVec(hDiffClump,hClump,hInQ,hInCI,hQOut,hCIOut,hOut2,hModeOut2,hGlobalMF,hICsystem,hModeDTC)

    lineCounter=1;


    if~isempty(hDiffClump)

        lineDst{lineCounter}=strcat(get_param(hDiffClump,'name'),'/5');
        lineSrc{lineCounter}=strcat(get_param(hInQ,'name'),'/1');
        lineCounter=lineCounter+1;

        lineDst{lineCounter}=strcat(get_param(hDiffClump,'name'),'/6');
        lineSrc{lineCounter}=strcat(get_param(hInCI,'name'),'/1');
        lineCounter=lineCounter+1;

    end

    if~isempty(hGlobalMF)

        lineDst{lineCounter}=strcat(get_param(hGlobalMF,'name'),'/4');
        lineSrc{lineCounter}=strcat(get_param(hICsystem,'name'),'/3');
        lineCounter=lineCounter+1;


        lineDst{lineCounter}=strcat(get_param(hGlobalMF,'name'),'/5');
        lineSrc{lineCounter}=strcat(get_param(hICsystem,'name'),'/4');
        lineCounter=lineCounter+1;
    end


    for i=1:numel(hClump)

        lineDst{lineCounter}=strcat(get_param(hClump(i),'name'),'/5');
        lineSrc{lineCounter}=strcat(get_param(hICsystem,'name'),'/3');
        lineCounter=lineCounter+1;


        lineDst{lineCounter}=strcat(get_param(hClump(i),'name'),'/6');
        lineSrc{lineCounter}=strcat(get_param(hICsystem,'name'),'/4');
        lineCounter=lineCounter+1;

    end



    lineDst{lineCounter}=strcat(get_param(hICsystem,'name'),'/3');
    lineSrc{lineCounter}=strcat(get_param(hInQ,'name'),'/1');
    lineCounter=lineCounter+1;

    lineDst{lineCounter}=strcat(get_param(hICsystem,'name'),'/4');
    lineSrc{lineCounter}=strcat(get_param(hInCI,'name'),'/1');
    lineCounter=lineCounter+1;


    lineDst{lineCounter}=strcat(get_param(hQOut,'name'),'/1');
    lineSrc{lineCounter}=strcat(get_param(hICsystem,'name'),'/3');
    lineCounter=lineCounter+1;

    lineDst{lineCounter}=strcat(get_param(hCIOut,'name'),'/1');
    lineSrc{lineCounter}=strcat(get_param(hICsystem,'name'),'/4');
    lineCounter=lineCounter+1;



    if(numel(hClump)>0)
        lineDst{lineCounter}=strcat(get_param(hOut2,'name'),'/1');
        lineSrc{lineCounter}=strcat(get_param(hClump(numel(hClump)),'name'),'/1');
        lineCounter=lineCounter+1;

        lineDst{lineCounter}=strcat(get_param(hModeOut2,'name'),'/1');
        lineSrc{lineCounter}=strcat(get_param(hClump(numel(hClump)),'name'),'/2');
    elseif~isempty(hDiffClump)
        lineDst{lineCounter}=strcat(get_param(hOut2,'name'),'/1');
        lineSrc{lineCounter}=strcat(get_param(hDiffClump,'name'),'/1');
        lineCounter=lineCounter+1;

        if~isempty(hGlobalMF)

            lineDst{lineCounter}=strcat(get_param(hModeOut2,'name'),'/1');
            lineSrc{lineCounter}=strcat(get_param(hModeDTC,'name'),'/1');
            lineCounter=lineCounter+1;
        else
            lineDst{lineCounter}=strcat(get_param(hModeOut2,'name'),'/1');
            lineSrc{lineCounter}=strcat(get_param(hDiffClump,'name'),'/2');
            lineCounter=lineCounter+1;
        end
    else

        lineDst{lineCounter}=strcat(get_param(hOut2,'name'),'/1');
        lineSrc{lineCounter}=strcat(get_param(hICsystem,'name'),'/1');
        lineCounter=lineCounter+1;

        lineDst{lineCounter}=strcat(get_param(hModeOut2,'name'),'/1');
        lineSrc{lineCounter}=strcat(get_param(hICsystem,'name'),'/2');
        lineCounter=lineCounter+1;
    end



end


