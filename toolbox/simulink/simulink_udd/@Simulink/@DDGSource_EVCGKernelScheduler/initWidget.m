function widgetStruct=initWidget(this,paramName,dlgRefresh)





    block=this.getBlock;

    widgetStruct.Name=block.IntrinsicDialogParameters.(paramName).Prompt;
    switch block.IntrinsicDialogParameters.(paramName).Type
    case 'enum'
        widgetStruct.Type='combobox';
        widgetStruct.Entries=block.getPropAllowedValues(paramName)';
        widgetStruct.Value=this.getEnumValFromStr(this.DialogData.(paramName),...
        widgetStruct.Entries);
    case 'string'
        widgetStruct.Type='edit';
        widgetStruct.Value=this.DialogData.(paramName);

    case 'boolean'
        widgetStruct.Type='checkbox';
        widgetStruct.Value=isequal(this.DialogData.(paramName),'on');
    end
    widgetStruct.Enabled=~this.isHierarchySimulating;
    widgetStruct.DialogRefresh=1;

    widgetStruct.Source=this;
    widgetStruct.ObjectMethod='ParamWidgetCallback';
    widgetStruct.MethodArgs={'%dialog',paramName,dlgRefresh,'%value'};
    widgetStruct.ArgDataTypes={'handle','string','bool','mxArray'};
end
