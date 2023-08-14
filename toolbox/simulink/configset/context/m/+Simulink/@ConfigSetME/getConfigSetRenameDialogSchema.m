function dlg=getConfigSetRenameDialogSchema(obj,~)




    tag='Tag_ConfigSetME_Rename_';
    widgetId='Simulink.ConfigSetME.Rename_';


    widget=[];
    widget.Name=message('RTW:configSet:refName').getString;
    widget.ObjectProperty='Name';
    widget.Source=obj.node;
    widget.Type='edit';
    widget.Enabled=~widget.Source.isReadonlyProperty(widget.ObjectProperty);
    widget.Mode=0;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.WidgetId=[widgetId,widget.ObjectProperty];
    widget.ToolTip=getString(message('RTW:configSet:configSetRefNameToolTip'));
    name=widget;
    name.RowSpan=[1,1];
    name.ColSpan=[1,1];

    dlg.DialogTitle=getString(message('Simulink:ConfigSet:ConfigSetMERenameDialogTitle'));
    dlg.Items={name};
    dlg.LayoutGrid=[1,1];
    dlg.StandaloneButtonSet={'OK','Cancel'};
