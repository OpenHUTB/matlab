function dnnfpgaPaddinglogiclibRenderDUT(gcb,threadNum,dataType)




    if isempty(threadNum)
        return;
    end

    try


        lines=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FindAll','on','type','line');
        delete_line(lines);


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

        createBlocks(gcb,threadNum,dataType);
    catch me
        disp(me.message);
    end

end

function createBlocks(gcb,threadNum,dataType)

    if strcmp(dataType,'single')
        dataType='uint32';
    end


    startX=100*threadNum+100;
    startY=0;
    blockWidth=20;
    blockHeight=50*threadNum;
    curX=startX;
    curY=startY;
    for i=1:threadNum
        curBlockName=[gcb,sprintf('/Vector Concatenate%d',i)];
        curY=curY+blockHeight+50;
        add_block('hdlsllib/Signal Routing/Vector Concatenate',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
        set_param(curBlockName,'NumInputs','threadNum');


        for j=1:(threadNum-i)
            curBlockName=[gcb,sprintf('/Constant%d_%d',i,j)];

            add_block('hdlsllib/Sources/Constant',curBlockName,'Position',[curX-250,curY+65+50*(i+j-2),curX-250+20,curY+65+20+50*(i+j-2)]);
            set_param(curBlockName,'value','0','SampleTime','-1','OutDataTypeStr',dataType);

            curBlockName=[gcb,sprintf('/Replicator%d_%d',i,j)];
            add_block('dnnfpgaSharedGenericlib/Scalar Replicator',curBlockName,'Position',[curX-150,curY+65+50*(i+j-2),curX-150+70,curY+65+20+50*(i+j-2)]);
            set_param(curBlockName,'width','BIN_SIZE');

            add_line(gcb,sprintf('Constant%d_%d/1',i,j),sprintf('Replicator%d_%d/1',i,j));
            add_line(gcb,sprintf('Replicator%d_%d/1',i,j),sprintf('Vector Concatenate%d/%d',i,i+j));
        end
    end


    curX=curX+300;
    curY=(threadNum+1)/2*(blockHeight+50);
    blockWidth=50;
    blockHeight=50*threadNum;
    curBlockName=[gcb,'/Multiport Switch1'];
    add_block('hdlsllib/Signal Routing/Multiport Switch',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
    set_param(curBlockName,'DataPortOrder','Zero-based contiguous','Inputs','threadNum+1');

    curBlockName=[gcb,sprintf('/ConstantMulti0')];
    add_block('hdlsllib/Sources/Constant',curBlockName,'Position',[curX-200,curY+40,curX-200+20,curY+40+20]);
    set_param(curBlockName,'value','0','SampleTime','-1','OutDataTypeStr',dataType);

    curBlockName=[gcb,sprintf('/ReplicatorMulti0')];
    add_block('dnnfpgaSharedGenericlib/Scalar Replicator',curBlockName,'Position',[curX-120,curY+40,curX-120+70,curY+40+20]);
    set_param(curBlockName,'width','BIN_SIZE*threadNum');

    add_line(gcb,sprintf('ConstantMulti0/1'),sprintf('ReplicatorMulti0/1'));
    add_line(gcb,sprintf('ReplicatorMulti0/1'),sprintf('Multiport Switch1/2'));


    startX=0;
    startY=(threadNum+1)*(blockHeight+50);
    blockWidth=30;
    blockHeight=60;
    curX=startX;
    curY=startY;
    for i=1:(threadNum-1)
        curBlockName=[gcb,sprintf('/Delay%d',i)];
        curX=curX+100;
        add_block('hdlsllib/Discrete/Delay',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
        set_param(curBlockName,'DelayLength','1','ShowEnablePort','on');
    end



    for i=1:threadNum
        srcPortName=sprintf('Vector Concatenate%d/1',i);
        destPortName=sprintf('Multiport Switch1/%d',i+2);
        add_line(gcb,srcPortName,destPortName,'autorouting','on');
    end

    for i=1:(threadNum-2)
        srcPortName=sprintf('Delay%d/1',i);
        destPortName=sprintf('Delay%d/1',i+1);
        add_line(gcb,srcPortName,destPortName,'autorouting','on');
        for j=(i+1):threadNum
            destPortName=sprintf('Vector Concatenate%d/%d',j,j-i);
            add_line(gcb,srcPortName,destPortName,'autorouting','on');
        end
    end

    srcPortName=sprintf('Delay%d/1',threadNum-1);
    destPortName=sprintf('Vector Concatenate%d/1',threadNum);
    add_line(gcb,srcPortName,destPortName,'autorouting','on');



    srcPortName='dataIn/1';
    for i=1:threadNum
        destPortName=sprintf('Vector Concatenate%d/%d',i,i);
        add_line(gcb,srcPortName,destPortName,'autorouting','on');
    end
    destPortName='Delay1/1';
    add_line(gcb,srcPortName,destPortName,'autorouting','on');

    srcPortName='valid/1';
    for i=1:(threadNum-1)
        destPortName=sprintf('Delay%d/2',i);
        add_line(gcb,srcPortName,destPortName,'autorouting','on');
    end

    srcPortName='Z/1';
    destPortName='Multiport Switch1/1';
    add_line(gcb,srcPortName,destPortName,'autorouting','on');

    srcPortName='Multiport Switch1/1';
    destPortName='dataOut/1';
    add_line(gcb,srcPortName,destPortName,'autorouting','on');

end
