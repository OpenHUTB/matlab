




function dnnfpgaGAPOutData(gcb,convThreadNum,fcThreadNum)

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

        if(convThreadNum==fcThreadNum)
            srcPortName=sprintf('inData/1');
            destPortName=sprintf('outData/1');
            add_line(gcb,srcPortName,destPortName,'autorouting','on');
        else
            createBlocks(gcb,convThreadNum,fcThreadNum);
        end

    catch me
        disp(me.message);
    end

end

function createBlocks(gcb,convThreadNum,fcThreadNum)

    curBlockName=[gcb,sprintf('/outData')];
    set_param(curBlockName,'position',[500,100,540,120]);

    if(convThreadNum>fcThreadNum)
        add_block('built-in/Terminator',[gcb,'/Terminate'],'position',[200,100,210,110]);
        add_line(gcb,'inData/1','Terminate/1','autorouting','on')

        curBlockName=[gcb,sprintf('/Constant1')];

        add_block('hdlsllib/Sources/Constant',curBlockName,'Position',[300,110,320,130]);
        set_param(curBlockName,'value','zeros((threadNumLimit),1)','SampleTime','-1','OutDataTypeStr','Inherit: Inherit via back propagation');
        add_line(gcb,'Constant1/1','outData/1','autorouting','on');
    else
        curBlockName=[gcb,sprintf('/Vector Concatenate1')];
        blockWidth=20;
        blockHeight=60;
        add_block('hdlsllib/Signal Routing/Vector Concatenate',curBlockName,'Position',[400,80,400+blockWidth,80+blockHeight]);
        set_param(curBlockName,'NumInputs','2');

        curBlockName=[gcb,sprintf('/Constant1')];

        add_block('hdlsllib/Sources/Constant',curBlockName,'Position',[200,110,220,130]);
        set_param(curBlockName,'value','zeros((threadNumLimit-FCDataDim),1)','SampleTime','-1','OutDataTypeStr','Inherit: Inherit via back propagation');

        destPortName=sprintf('Vector Concatenate1/1');
        add_line(gcb,'inData/1',destPortName,'autorouting','on');
        destPortName=sprintf('Vector Concatenate1/2');
        add_line(gcb,'Constant1/1',destPortName,'autorouting','on');

        add_line(gcb,'Vector Concatenate1/1','outData/1','autorouting','on');
    end

end
