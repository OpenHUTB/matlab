



















function dnnfpgaRemovePaddedZeros(gcb,fcThreadNum,SumLatency)

    if isempty(fcThreadNum)
        return;
    end

    if isempty(SumLatency)
        return;
    end

    try


        blocks=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all');
        for i=1:length(blocks)
            if(strcmp(get_param(blocks{i},'BlockType'),'SubSystem')&&...
                strcmp(get_param(blocks{i},'Name'),get_param(gcb,'Name')))||...
                strcmp(get_param(blocks{i},'BlockType'),'Inport')||...
                strcmp(get_param(blocks{i},'BlockType'),'Outport')
                continue;
            end
            delete_block(blocks{i});
        end


        lines=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FindAll','on','type','line');
        delete_line(lines);

        createBlocks(gcb,fcThreadNum,SumLatency);

    catch me
        disp(me.message);
    end

end

function createBlocks(gcb,fcThreadNum,SumLatency)

    curBlockName=[gcb,sprintf('/enable')];
    set_param(curBlockName,'position',[220,-100,260,-80]);

    curBlockName=[gcb,sprintf('/paddedZeros')];
    set_param(curBlockName,'position',[120,0,160,20]);

    curBlockName=[gcb,sprintf('/outData')];
    set_param(curBlockName,'position',[2000,100,2040,120]);


    srcPortName=sprintf('inData/1');
    index=1;
    for i=1:fcThreadNum-1

        curBlockName=[gcb,sprintf('/Demux%d',i)];
        add_block('hdlsllib/Commonly Used Blocks/Demux',curBlockName);
        set_param(curBlockName,'Outputs',num2str(fcThreadNum));
        set_param(curBlockName,'position',[200,200+i*200,205,300+i*200]);

        destPortName=sprintf('Demux%d/1',i);
        add_line(gcb,srcPortName,destPortName,'autorouting','on');

        for j=1:i
            curBlockName=[gcb,sprintf('/Terminator%d',index)];
            add_block('hdlsllib/Sinks/Terminator',curBlockName);
            set_param(curBlockName,'position',[300,200+fcThreadNum*200,340,220+fcThreadNum*200]);

            srcPortName1=sprintf('Demux%d/%d',i,fcThreadNum-j+1);
            destPortName1=sprintf('Terminator%d/1',index);
            add_line(gcb,srcPortName1,destPortName1,'autorouting','on');
            index=index+1;
        end

        curBlockName=[gcb,sprintf('/VectorConcatenate%d',i)];
        add_block('hdlsllib/Signal Routing/Vector Concatenate',curBlockName,'Position',[450,200+i*200,455,300+i*200]);
        set_param(curBlockName,'NumInputs',num2str(fcThreadNum));

        for j=1:i
            curBlockName=[gcb,sprintf('/Constant%d',index)];
            add_block('hdlsllib/Sources/Constant',curBlockName,'Position',[350,200+fcThreadNum*200,380,220+fcThreadNum*200]);
            set_param(curBlockName,'value','0','SampleTime','-1','OutDataTypeStr','single');

            srcPortName1=sprintf('Constant%d/1',index);
            destPortName1=sprintf('VectorConcatenate%d/%d',i,fcThreadNum-j+1);
            add_line(gcb,srcPortName1,destPortName1,'autorouting','on');
            index=index+1;
        end

        for j=1:fcThreadNum-i
            srcPortName2=sprintf('Demux%d/%d',i,j);
            destPortName2=sprintf('VectorConcatenate%d/%d',i,j);
            add_line(gcb,srcPortName2,destPortName2,'autorouting','on');
        end

    end

    curBlockName=[gcb,sprintf('/MultiportSwitch1')];
    add_block('hdlsllib/Signal Routing/Multiport Switch',curBlockName,'Position',[600,100,650,100+fcThreadNum*50]);
    set_param(curBlockName,'Inputs',num2str(fcThreadNum));

    set_param(curBlockName,'DataPortForDefault','Last data port');
    set_param(curBlockName,'DataPortOrder','Zero-based contiguous');

    srcPortName=sprintf('paddedZeros/1');
    destPortName=sprintf('MultiportSwitch1/1');
    add_line(gcb,srcPortName,destPortName,'autorouting','on');

    srcPortName=sprintf('inData/1');
    destPortName=sprintf('MultiportSwitch1/2');
    add_line(gcb,srcPortName,destPortName,'autorouting','on');

    for i=1:fcThreadNum-1
        srcPortName=sprintf('VectorConcatenate%d/1',i');
        destPortName=sprintf('MultiportSwitch1/%d',i+2);
        add_line(gcb,srcPortName,destPortName,'autorouting','on');
    end


    curBlockName=[gcb,sprintf('/Switch')];
    add_block('hdlsllib/Signal Routing/Switch',curBlockName);

    set_param(curBlockName,'Criteria','u2 ~= 0','OutDataTypeStr','Inherit: Inherit via back propagation','Threshold','0');
    set_param(curBlockName,'position',[700,100,750,150]);

    srcPortName=sprintf('MultiportSwitch1/1');
    destPortName=sprintf('Switch/1');
    add_line(gcb,srcPortName,destPortName,'autorouting','on');

    srcPortName=sprintf('enable/1');
    destPortName=sprintf('Switch/2');
    add_line(gcb,srcPortName,destPortName,'autorouting','on');

    srcPortName=sprintf('inData/1');
    destPortName=sprintf('Switch/3');
    add_line(gcb,srcPortName,destPortName,'autorouting','on');




    curBlockName=[gcb,sprintf('/DemuxFinal')];
    add_block('hdlsllib/Commonly Used Blocks/Demux',curBlockName);
    set_param(curBlockName,'Outputs',num2str(fcThreadNum));
    set_param(curBlockName,'position',[800,100,805,100+fcThreadNum*50]);

    srcPortName=sprintf('Switch/1');
    destPortName=sprintf('DemuxFinal/1');
    add_line(gcb,srcPortName,destPortName,'autorouting','on');



    numStages=log(fcThreadNum);
    totalAdders=fcThreadNum-1;
    stage=0;
    totalInputs=fcThreadNum;
    index=1;
    while(floor(totalInputs/2)~=0)
        numAddersInCurrentStage=floor(totalInputs/2);
        p=[];
        for j=1:numAddersInCurrentStage
            curBlockName=[gcb,sprintf('/Add%d',index)];
            add_block('hdlsllib/Math Operations/Add',curBlockName,'Position',[900+stage*200,100+j*50,940+stage*200,140+j*50]);
            set_param(curBlockName,'Inputs','2','OutDataTypeStr','Inherit: Inherit via back propagation');

            curBlockName=[gcb,sprintf('/Delay%d',index)];
            add_block('hdlsllib/Discrete/Delay',curBlockName,'Position',[1000+stage*200,100+j*50,1040+stage*200,140+j*50]);
            set_param(curBlockName,'DelayLength',num2str(SumLatency));

            if(stage==0)
                port=1;
                for k=index*2-1:index*2
                    srcPortName=sprintf('DemuxFinal/%d',k);
                    destPortName=sprintf('Add%d/%d',index,port);
                    add_line(gcb,srcPortName,destPortName,'autorouting','on');
                    port=port+1;
                end
            else
                if(isempty(p))
                    numAddersInPreviousStage=numAddersInCurrentStage*2;
                    previousStageStartIndex=index-numAddersInPreviousStage;
                    p=previousStageStartIndex;
                end
                for port=1:2
                    srcPortName=sprintf('Delay%d/1',p);
                    destPortName=sprintf('Add%d/%d',index,port);
                    add_line(gcb,srcPortName,destPortName,'autorouting','on');
                    p=p+1;
                end
            end

            srcPortName1=sprintf('Add%d/1',index);
            destPortName1=sprintf('Delay%d/1',index);
            add_line(gcb,srcPortName1,destPortName1,'autorouting','on');

            index=index+1;
        end
        totalInputs=totalInputs/2;
        stage=stage+1;
    end

    finalAdditionBlockIndex=index-1;
    srcPortName=sprintf('Delay%d/1',finalAdditionBlockIndex);
    destPortName=sprintf('outData/1');
    add_line(gcb,srcPortName,destPortName,'autorouting','on');















end
