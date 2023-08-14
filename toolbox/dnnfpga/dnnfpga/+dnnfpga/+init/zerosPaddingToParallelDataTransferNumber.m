function zerosPaddingToParallelDataTransferNumber(gcb,threadNum,dataTransNum,dataType)
















    if isempty(threadNum)
        return;
    end
    if isempty(dataTransNum)
        return;
    end
    if isempty(dataType)
        return;
    end
    if~threadNum
        disp('threadNum value is zero');
        return;
    end
    if~dataTransNum
        disp('dataTransNum value is zero');
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
    catch me
        disp(me.message);
    end

    if dataTransNum==threadNum

        add_line(gcb,'inData/1','outData/1','autorouting','on');
    else

        padSize=dataTransNum-threadNum;


        curBlockName=[gcb,sprintf('/zeros constant1')];
        add_block('hdlsllib/Sources/Constant',curBlockName);
        set_param(curBlockName,'OutDataTypeStr',dataType,'value',sprintf('zeros(1,%d)',padSize));


        curBlockName=[gcb,sprintf('/Vector Concatenate1')];
        add_block('hdlsllib/Signal Routing/Vector Concatenate',curBlockName);
        set_param(curBlockName,'NumInputs','2');


        add_line(gcb,'inData/1','Vector Concatenate1/1','autorouting','on');
        add_line(gcb,'zeros constant1/1','Vector Concatenate1/2','autorouting','on');
        add_line(gcb,'Vector Concatenate1/1','outData/1','autorouting','on');
    end


end
