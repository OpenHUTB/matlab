function renderRAMSystem(gcb,RAMNum)










    if isempty(RAMNum)
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

        createBlocks(gcb,RAMNum);
    catch me
        disp(me.message);
    end

end

function createBlocks(gcb,RAMNum)


    startX=0;
    startY=0;










    if(RAMNum==1)
        curX=startX;
        curY=startY;
        blockWidth=150;
        blockHeight=200;
        add_block('hdlsllib/HDL RAMs/Simple Dual Port RAM System',[gcb,'/RAM System1'],'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
        set_param([gcb,'/RAM System1'],'RAMInitialValue','[INIT_DATA zeros(1,65536-length(INIT_DATA))]');
        add_line(gcb,'ddr_din/1','RAM System1/1','autorouting','on');
        add_line(gcb,'ddr_wr_addr/1','RAM System1/2','autorouting','on');
        add_line(gcb,'ddr_wr_en/1','RAM System1/3','autorouting','on');
        add_line(gcb,'ddr_rd_addr/1','RAM System1/4','autorouting','on');
        add_line(gcb,'RAM System1/1','ddr_dout/1','autorouting','on');
    else


        curX=startX;
        curY=startY;
        blockWidth=150;
        blockHeight=200;
        add_block('hdlsllib/Signal Routing/Demux',[gcb,'/Demux1'],'Position',[curX-220,curY+100,curX-210,curY+200]);
        set_param([gcb,'/Demux1'],'Outputs','RAMNum');


        curX=startX;
        curY=startY;
        for i=1:RAMNum
            curY=curY+250;
            add_block('hdlsllib/HDL RAMs/Simple Dual Port RAM System',[gcb,sprintf('/RAM System%d',i)],'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
            set_param([gcb,sprintf('/RAM System%d',i)],'RAMInitialValue',sprintf('[INIT_DATA(%d,:) zeros(1,65536-length(INIT_DATA(%d,:)))]',i,i));
        end


        curX=startX;
        curY=startY;
        curBlockName=[gcb,sprintf('/Vector Concatenate1')];
        add_block('hdlsllib/Signal Routing/Vector Concatenate',curBlockName,'Position',[curX+300,curY+100,curX+310,curY+200]);
        set_param(curBlockName,'NumInputs','RAMNum');




        add_line(gcb,'ddr_din/1','Demux1/1','autorouting','on');
        for i=1:RAMNum
            srcPortName=sprintf('Demux1/%d',i);
            destPortName=sprintf('RAM System%d/1',i);
            add_line(gcb,srcPortName,destPortName,'autorouting','on');
        end


        add_line(gcb,'Vector Concatenate1/1','ddr_dout/1','autorouting','on');
        for i=1:RAMNum
            srcPortName=sprintf('RAM System%d/1',i);
            destPortName=sprintf('Vector Concatenate1/%d',i);
            add_line(gcb,srcPortName,destPortName,'autorouting','on');
        end


        for i=1:RAMNum
            add_line(gcb,'ddr_wr_addr/1',sprintf('RAM System%d/2',i),'autorouting','on');
            add_line(gcb,'ddr_wr_en/1',sprintf('RAM System%d/3',i),'autorouting','on');
            add_line(gcb,'ddr_rd_addr/1',sprintf('RAM System%d/4',i),'autorouting','on');
        end

    end


end
