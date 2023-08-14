function dnnfpgaSharedRenderVectorReplicator(gcb,dim,width)







    if(isempty(dim))
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

        createBlocks(gcb,dim,width);
    catch me
        disp(me.message);
    end

end

function createBlocks(gcb,dim,width)


    startX=0;
    startY=0;


    curX=startX;
    curY=startY;
    blockWidth=10;
    blockHeight=40*dim;
    add_block('hdlsllib/Signal Routing/Demux',[gcb,'/Demux1'],'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
    set_param([gcb,'/Demux1'],'Outputs',num2str(dim));


    curX=curX+100;
    for i=1:dim
        add_block('hdlsllib/Signal Routing/Mux',[gcb,'/Mux',num2str(i)],'Position',[curX,curY,curX+10,curY+40]);
        set_param([gcb,'/Mux',num2str(i)],'Inputs',num2str(width));
        curY=curY+50;
    end


    curX=startX+200;
    curY=startY;
    curBlockName=[gcb,sprintf('/Vector Concatenate1')];
    add_block('hdlsllib/Signal Routing/Vector Concatenate',curBlockName,'Position',[curX,curY,curX+blockWidth,curY+blockHeight]);
    set_param(curBlockName,'NumInputs',num2str(dim));


    add_line(gcb,'inData/1','Demux1/1','autorouting','on');
    add_line(gcb,'Vector Concatenate1/1','outData/1','autorouting','on');


    for i=1:dim
        for j=1:width
            add_line(gcb,sprintf('Demux1/%d',i),sprintf('Mux%d/%d',i,j),'autorouting','on');
        end
        add_line(gcb,sprintf('Mux%d/1',i),sprintf('Vector Concatenate1/%d',i),'autorouting','on');
    end



end

