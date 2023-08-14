function refreshEditorHighlight(cbinfo,action)



    if strcmp(get_param(cbinfo.model.name,'ReqHilite'),'on')
        action.selected=true;
    else
        action.selected=false;
    end


end
