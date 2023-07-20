



function portDataTypeDisplayRF(userdata,cbinfo,action)
    neither_selected=strcmpi(get_param(cbinfo.editorModel.handle,'ShowPortDataTypes'),'off');

    if neither_selected
        action.selected=false;
    else
        both_selected=strcmpi(get_param(cbinfo.editorModel.handle,'PortDataTypeDisplayFormat'),'BaseAndAliasTypes');
        alias_selected=strcmpi(get_param(cbinfo.editorModel.handle,'PortDataTypeDisplayFormat'),'AliasTypeOnly')||both_selected;
        base_selected=strcmpi(get_param(cbinfo.editorModel.handle,'PortDataTypeDisplayFormat'),'BaseTypeOnly')||both_selected;

        switch userdata
        case 'base'
            action.selected=base_selected;
        case 'alias'
            action.selected=alias_selected;
        end
    end
end
