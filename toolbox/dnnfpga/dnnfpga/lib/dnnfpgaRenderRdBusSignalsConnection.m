function dnnfpgaRenderRdBusSignalsConnection(gcb,inputsNum)








    if isempty(inputsNum)
        return;
    end
    assert(inputsNum>1,'Number of Inputs need to be larger than 1')

    try


        blocks=find_system(gcb,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all');
        for i=1:length(blocks)


            if(strcmp(get_param(blocks{i},'BlockType'),'Inport')&&...
                contains(get_param(blocks{i},'Name'),'axi_rd_m2s_in','IgnoreCase',true))||...
                (strcmpi(get_param(blocks{i},'BlockType'),'BusSelector')&&...
                contains(get_param(blocks{i},'Name'),'axi_rd_m2s_bs_in','IgnoreCase',true))
                try %#ok<*TRYNC>

                    delete_line(get_param(blocks{i},'LineHandles').Outport);
                end

                delete_block(blocks{i});
            end
        end
        createBusConnection(gcb,inputsNum);
    end

end

function createBusConnection(gcb,inputsNum)

    startX=0;
    startY=0;


    for i=1:inputsNum
        curX=startX;
        curY=startY+i*300;
        curBlockName=[gcb,sprintf('/axi_rd_m2s_in%d',i)];
        add_block('hdlsllib/Sources/In1',curBlockName,'Position',[curX,curY,curX+40,curY+20]);
        set_param(curBlockName,'Name',sprintf('axi_rd_m2s_in%d',i));
    end


    for i=1:inputsNum
        curX=startX+100;
        curY=startY-45+i*300;
        curBlockName=[gcb,sprintf('/axi_rd_m2s_bs_in%d',i)];
        add_block('dnnfpgaReadWriteBusTemplate/rd_m2s_bus',curBlockName,'Position',[curX,curY,curX+5,curY+100]);
        set_param(curBlockName,'Name',sprintf('axi_rd_m2s_bs_in%d',i));
    end

    set_param([gcb,'/Multiport Switch start'],'Inputs','NumOfInputs');
    set_param([gcb,'/Multiport Switch length'],'Inputs','NumOfInputs');
    set_param([gcb,'/Multiport Switch offset'],'Inputs','NumOfInputs');
    set_param([gcb,'/Multiport Switch dready'],'Inputs','NumOfInputs');



    for i=1:inputsNum
        add_line(gcb,sprintf('axi_rd_m2s_in%d/1',i),sprintf('axi_rd_m2s_bs_in%d/1',i),'autorouting','on');
    end


    for i=1:inputsNum
        add_line(gcb,sprintf('axi_rd_m2s_bs_in%d/1',i),sprintf('Multiport Switch start/%d',i+1),'autorouting','on');
        add_line(gcb,sprintf('axi_rd_m2s_bs_in%d/2',i),sprintf('Multiport Switch length/%d',i+1),'autorouting','on');
        add_line(gcb,sprintf('axi_rd_m2s_bs_in%d/3',i),sprintf('Multiport Switch offset/%d',i+1),'autorouting','on');
        add_line(gcb,sprintf('axi_rd_m2s_bs_in%d/4',i),sprintf('Multiport Switch dready/%d',i+1),'autorouting','on');
    end

end

