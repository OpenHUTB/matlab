function dlg=getConfigSetRefDialogSchema(hController,schemaName)




    reference=configset.dialog.HTMLView.getConfigSetRefDialogSchema(hController,schemaName);

    hSrc=hController.getSourceObject;

    tag='Tag_ConfigSetRef_';
    widgetId='Simulink.ConfigSetRef.';


    widget=[];
    widget.Type='text';
    widget.Name=[getString(message('RTW:configSet:configSetRefPropertiesDescr'))...
    ,newline,newline...
    ,getString(message('RTW:configSet:configSetRefPropertiesDetailedDescr'))];
    widget.WordWrap=true;
    widget.WidgetId=[widgetId,'configSetRefPropertiesDescr'];
    widget.Tag=[tag,'configSetRefPropertiesDescr'];
    description=widget;


    widget=[];
    widget.Type='group';
    widget.Name=getString(message('RTW:configSet:configSetRefPropertiesTitle'));
    widget.WidgetId=[widgetId,'configSetRefPropertiesTitle'];
    widget.Tag=[tag,'configSetRefPropertiesTitle'];
    widget.Items={description};
    info=widget;


    widget=[];
    widget.Name=message('RTW:configSet:refDescrName').getString;
    widget.Type='editarea';
    widget.ObjectProperty='Description';
    widget.Enabled=~hSrc.isReadonlyProperty('Description');
    widget.Tag=[tag,widget.ObjectProperty];
    widget.WidgetId=[widgetId,widget.ObjectProperty];
    widget.Mode=false;
    widget.PreferredSize=[-1,40];
    desc=widget;

    if~isempty(hSrc.getModel)&&hSrc.isActive
        dlg.DisplayIcon='toolbox/shared/dastudio/resources/ActiveConfigurationReference.png';
    else
        dlg.DisplayIcon='toolbox/shared/dastudio/resources/ConfigurationReference.png';
    end

    helpdest='ConfigSetRef';
    dlg.DialogTitle=hController.getDialogTitle;

    dlg.Items={info,reference{1},desc};
    dlg.LayoutGrid=[4,1];
    dlg.RowStretch=[0,0,0,1];
    dlg.HelpMethod='slprivate';
    dlg.HelpArgs={'configHelp','%dialog',hController,schemaName,helpdest};
    if slfeature('ConfigSetRefOverride')
        dlg.StandaloneButtonSet={'OK','Cancel','Apply','Help'};
    else
        dlg.StandaloneButtonSet={'OK','Apply','Help'};
    end
    dlg.EmbeddedButtonSet={'Revert','Apply','Help'};
    dlg.DefaultOk=false;

    if~isempty(hController.DataDictionary)
        dlg.PreApplyCallback='configset.internal.util.dataDictionaryDialogCallback';
        dlg.PreApplyArgs={hController,'apply'};
        dlg.PostRevertCallback='configset.internal.util.dataDictionaryDialogCallback';
        dlg.PostRevertArgs={hController,'revert'};
    end



