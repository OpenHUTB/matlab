



function hideAutomaticBlockNamesRF(cbinfo,action)
    isSelected=false;

    if(strcmp(get_param(cbinfo.model.Name,'HideAutomaticNames'),'on'))
        isSelected=true;
    end
    action.selected=isSelected;
end


