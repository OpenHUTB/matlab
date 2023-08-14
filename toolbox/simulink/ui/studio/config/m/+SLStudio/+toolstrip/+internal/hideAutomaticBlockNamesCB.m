



function hideAutomaticBlockNamesCB(cbinfo)
    blockDiagram=cbinfo.model.handle;

    if(strcmp(get_param(blockDiagram,'HideAutomaticNames'),'off'))
        set_param(blockDiagram,'HideAutomaticNames','on');
    else
        set_param(blockDiagram,'HideAutomaticNames','off');
    end
end
