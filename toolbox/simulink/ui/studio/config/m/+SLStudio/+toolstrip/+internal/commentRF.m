



function commentRF(userdata,cbinfo,action)

    if SLStudio.Utils.isLockedSystem(cbinfo)
        action.enabled=0;
    end

    if~SLStudio.Utils.selectionHasBlocks(cbinfo)
        action.enabled=0;
    else
        blockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
        block=get_param(blockHandles,'Object');

        if isa(block,'Simulink.Outport')||isa(block,'Simulink.Inport')
            action.enabled=0;
        else
            action.enabled=1;
        end

        numBlocks=length(blockHandles);

        [~,commOut,commThrough]=loc_getCommentedStateOfBlocks(cbinfo);

        if(strcmp(userdata,'out'))
            if(commOut==numBlocks)
                action.selected=1;
            else
                action.selected=0;
            end
        elseif(strcmp(userdata,'through'))
            if(commThrough==numBlocks)
                action.selected=1;
            else
                action.selected=0;
            end
        elseif(strcmp(userdata,'off'))
            if(commOut==0&&commThrough==0)
                action.enabled=0;
            else
                action.enabled=1;
            end
        end
    end
end

function[uncomm,commOut,commThru]=loc_getCommentedStateOfBlocks(cbinfo)
    blockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);

    uncomm=0;commOut=0;commThru=0;

    for i=1:length(blockHandles)
        switch get_param(blockHandles(i),'Commented')
        case 'off'
            uncomm=uncomm+1;
        case 'on'
            commOut=commOut+1;
        case 'through'
            commThru=commThru+1;
        end
    end
end

