function schema=getConfigSetInfoDialogSchema(hController,~)




    name.Name=message('RTW:configSet:name1').getString;
    desc.Name=message('RTW:configSet:descr1').getString;
    launchCS.Name=message('RTW:configSet:viewCSDetailsName').getString;
    launchCS.ToolTip=message('RTW:configSet:viewCSDetailsTooltip').getString;

    tag='Tag_ConfigSet_';
    widgetId='Simulink.ConfigSet.';

    hSrc=hController.getSourceObject;
    isPrefs=isa(hSrc.up,'Simulink.Root');


    info.Type='textbrowser';
    info.Text=configset_info_l(hSrc);
    info.Visible=1;


    name.Type='edit';
    name.ObjectProperty='Name';
    name.Enabled=~hSrc.isReadonlyProperty('Name')&&~isPrefs;
    name.Mode=1;
    name.DialogRefresh=1;
    name.Tag=[tag,name.ObjectProperty];
    name.WidgetId=[widgetId,name.ObjectProperty];
    name.RowSpan=[1,1];
    name.ColSpan=[1,1];


    desc.Type='editarea';
    desc.ObjectProperty='Description';
    desc.Enabled=~hSrc.isReadonlyProperty('Description');
    desc.Tag=[tag,desc.ObjectProperty];
    desc.WidgetId=[widgetId,desc.ObjectProperty];
    desc.Mode=1;
    desc.PreferredSize=[-1,40];


    launchCS.Type='pushbutton';
    launchCS.Source=hController;
    launchCS.Tag=[tag,'LaunchCS'];
    launchCS.WidgetId=[widgetId,'LaunchCS'];
    launchCS.ObjectMethod='dialogCallback';
    launchCS.MethodArgs={'%dialog',launchCS.Tag,''};
    launchCS.ArgDataTypes={'handle','string','string'};
    launchCS.Enabled=~isObjectLocked(hSrc);

    launchCS.RowSpan=[1,1];
    launchCS.ColSpan=[2,2];

    group.Items={name,launchCS};
    group.LayoutGrid=[1,2];
    group.ColStretch=[1,0];
    group.Type='panel';

    info.RowSpan=[1,1];
    group.RowSpan=[2,2];
    desc.RowSpan=[3,3];

    schema.DialogTitle=hController.getDialogTitle;
    schema.Items={info,group,desc};
    schema.LayoutGrid=[3,1];
    schema.RowStretch=[1,0,1];
    if~isempty(hController.DataDictionary)

        schema.PreApplyCallback='configset.internal.util.dataDictionaryDialogCallback';
        schema.PreApplyArgs={hController,'apply'};
        schema.PostRevertCallback='configset.internal.util.dataDictionaryDialogCallback';
        schema.PostRevertArgs={hController,'revert'};
    end

    function out=configset_info_l(hSrc)

        parent=hSrc.up;
        title='<b><font size=+3>%s</font></b>';
        table='<table><tr><td>%s</td></tr></table>';
        row='<tr><td align="right"><b>%s</b></td><td>%s</td></tr>';
        configName=['''',hSrc.Name,''''];

        switch class(parent)
        case 'Simulink.BlockDiagram'
            if hSrc.isActive
                isActiveStr='<font color="darkgreen">yes</font>';
            else
                isActiveStr='no';
            end
            modelName=sprintf('<a href="matlab:%s">%s</a>',parent.Name,parent.Name);
            htm=[sprintf(title,...
            message('RTW:configSet:configSetPropertiesTitle').getString),...
            sprintf(table,...
            message('RTW:configSet:configSetPropertiesDescr').getString),...
            '<table>',...
            sprintf(row,message('RTW:configSet:configSetPropertiesConfigName').getString,configName),...
            sprintf(row,message('RTW:configSet:configSetPropertiesAssoMdl').getString,modelName),...
            sprintf(row,message('RTW:configSet:configSetPropertiesIsActive').getString,isActiveStr),...
            '</table>'];

        otherwise
            htm=[sprintf(title,...
            message('RTW:configSet:configSetPropertiesTitle').getString),...
            sprintf(table,...
            message('RTW:configSet:configSetPropertiesDescr').getString),...
            '<br>',...
            message('RTW:configSet:configSetOtherwiseDescr').getString,...
            '<table>',...
            sprintf(row,message('RTW:configSet:configSetPropertiesConfigName').getString,configName),...
            '</table>',...
            ];
        end

        out=['<table width="100%" BORDER=0 CELLSPACING=0 CELLPADDING=0 bgcolor="#ededed">',...
        '<tr><td>',htm,'</td></tr></table>'];


