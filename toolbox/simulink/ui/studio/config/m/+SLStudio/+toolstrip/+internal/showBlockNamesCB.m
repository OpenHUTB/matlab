



function showBlockNamesCB(userdata,cbinfo)
    blockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    val=lower(userdata);
    selectedBlocksSize=length(blockHandles);
    for index=1:selectedBlocksSize
        if(strcmpi(val,'auto'))
            set_param(blockHandles(index),'HideAutomaticName','on');
            set_param(blockHandles(index),'ShowName','on');
        else
            set_param(blockHandles(index),'HideAutomaticName','off');
            set_param(blockHandles(index),'ShowName',val);
        end
    end
end

