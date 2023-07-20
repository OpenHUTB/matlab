


function inPanel=isBlockInWebPanel(blockHandle)
    inPanel=false;
    if(~utils.isWebBlock(blockHandle))
        return;
    end
    isCoreWebBlock=get_param(blockHandle,'isCoreWebBlock');
    if(~strcmp(isCoreWebBlock,'on'))
        return;
    end
    panelInfo=get_param(blockHandle,'PanelInfo');
    if(isempty(panelInfo))
        return;
    end
    inPanel=true;
end
