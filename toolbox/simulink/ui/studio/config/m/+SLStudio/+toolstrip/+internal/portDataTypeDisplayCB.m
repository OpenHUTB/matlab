



function portDataTypeDisplayCB(userdata,cbinfo)
    editorModel=cbinfo.editorModel.handle;
    port_type_data_display_format=get_param(editorModel,'PortDataTypeDisplayFormat');
    neither_selected=strcmpi(get_param(editorModel,'ShowPortDataTypes'),'off');
    both_selected=~neither_selected&&strcmpi(port_type_data_display_format,'BaseAndAliasTypes');
    alias_selected=~neither_selected&&strcmpi(port_type_data_display_format,'AliasTypeOnly');
    base_selected=~neither_selected&&strcmpi(port_type_data_display_format,'BaseTypeOnly');

    if neither_selected
        set_param(editorModel,'ShowPortDataTypes','on');
        SLM3I.SLDomain.updateDiagram(editorModel);
    end

    switch userdata
    case 'base'
        if both_selected
            set_param(editorModel,'PortDataTypeDisplayFormat','AliasTypeOnly');
        elseif alias_selected
            set_param(editorModel,'PortDataTypeDisplayFormat','BaseAndAliasTypes');
        elseif base_selected
            set_param(editorModel,'ShowPortDataTypes','off');
        else
            set_param(editorModel,'PortDataTypeDisplayFormat','BaseTypeOnly');
        end
    case 'alias'
        if both_selected
            set_param(editorModel,'PortDataTypeDisplayFormat','BaseTypeOnly');
        elseif base_selected
            set_param(editorModel,'PortDataTypeDisplayFormat','BaseAndAliasTypes');
        elseif alias_selected
            set_param(editorModel,'ShowPortDataTypes','off');
        else
            set_param(editorModel,'PortDataTypeDisplayFormat','AliasTypeOnly');
        end
    end
end
