





function dnnfpgaGAPDataConcatenate(gcb,convThreadNum,fcThreadNum)

    if isempty(convThreadNum)
        return;
    end

    if isempty(fcThreadNum)
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

        if(convThreadNum>=fcThreadNum)
            srcPortName=sprintf('inData/1');
            destPortName=sprintf('outData/1');
            add_line(gcb,srcPortName,destPortName,'autorouting','on');

            srcPortName=sprintf('inAddr/1');
            destPortName=sprintf('outAddr/1');
            add_line(gcb,srcPortName,destPortName,'autorouting','on');
        else
            createBlocks(gcb,convThreadNum,fcThreadNum);
        end

    catch me
        disp(me.message);
    end

end

function createBlocks(gcb,convThreadNum,fcThreadNum)

    curBlockName=[gcb,sprintf('/outAddr')];
    set_param(curBlockName,'position',[500,400,540,420]);

    curBlockName=[gcb,sprintf('/BitShift1')];
    add_block('hdlsllib/Logic and Bit Operations/Bit Shift',curBlockName,'Position',[200,400,240,440]);
    set_param(curBlockName,'mode','Shift Right Logical','N','log2(threadNumLimit/FCDataDim)');

    srcPortName=sprintf('inAddr/1');
    destPortName=sprintf('BitShift1/1');
    add_line(gcb,srcPortName,destPortName,'autorouting','on');

    srcPortName=sprintf('BitShift1/1');
    destPortName=sprintf('outAddr/1');
    add_line(gcb,srcPortName,destPortName,'autorouting','on');


    curBlockName=[gcb,sprintf('/Selector1')];
    add_block('hdlsllib/Signal Routing/Selector',curBlockName,'Position',[200,80,240,120]);
    set_param(curBlockName,'IndexMode','Zero-based','InputPortWidth','threadNumLimit','OutputSizes','FCDataDim','IndexOptions','Starting index (dialog)','NumberOfDimensions','1','Indices','0');

    srcPortName=sprintf('inData/1');
    destPortName=sprintf('Selector1/1');
    add_line(gcb,srcPortName,destPortName,'autorouting','on');


    curBlockName=[gcb,sprintf('/outData')];
    set_param(curBlockName,'position',[600,140,640,160]);

    delay=ceil((fcThreadNum-convThreadNum)/convThreadNum);

    for i=1:delay
        curBlockName=[gcb,sprintf('/Delay%d',i)];
        add_block('hdlsllib/Discrete/Delay',curBlockName);
        set_param(curBlockName,'position',[300,80+60*(delay-i),340,120+60*(delay-i)]);
        DelayLength=sprintf('%d',i);
        set_param(curBlockName,'DelayLength',DelayLength);
    end

    curBlockName=[gcb,sprintf('/Vector Concatenate1')];

    blockWidth=20;
    blockHeight=60*delay;
    add_block('hdlsllib/Signal Routing/Vector Concatenate',curBlockName,'Position',[500,80,500+blockWidth,80+blockHeight]);
    set_param(curBlockName,'NumInputs',num2str(ceil(fcThreadNum/convThreadNum)));




    for i=1:delay
        srcPortName=sprintf('Selector1/1');
        destPortName=sprintf('Delay%d/1',i);
        add_line(gcb,srcPortName,destPortName,'autorouting','on');
    end

    for i=1:delay
        srcPortName=sprintf('Delay%d/1',delay+1-i);
        destPortName=sprintf('Vector Concatenate1/%d',i);
        add_line(gcb,srcPortName,destPortName,'autorouting','on');
    end



    destPortName=sprintf('Vector Concatenate1/%d',delay+1);
    add_line(gcb,'Selector1/1',destPortName,'autorouting','on');
    add_line(gcb,'Vector Concatenate1/1','outData/1','autorouting','on');

end
