function dlgStruct=getMappingManagerDialogSchema(hSrc,~)








    descTxt.Type='textbrowser';
    descTxt.Text=configset_info_l(hSrc);
    descTxt.Visible=1;

    explicitMap.Name=DAStudio.message('Simulink:taskEditor:EnableExplicitTaskMappingChkbox');
    explicitMap.Type='checkbox';
    explicitMap.Tag='explicitMap_tag';
    explicitMap.ToolTip=DAStudio.message('Simulink:taskEditor:EnableExplicitTaskMappingToolTip');
    explicitMap.Value=strcmp(get_param(hSrc.ParentDiagram,'ExplicitPartitioning'),'on');
    explicitMap.MatlabMethod='DeploymentDiagram.callbackFunction';
    explicitMap.MatlabArgs={'explicitTaskMapping','%dialog','%value'};
    explicitMap.Enabled=true;
    explicitMap.DialogRefresh=true;
    explicitMap.Graphical=true;


    archPrompt.Name=DAStudio.message('Simulink:taskEditor:TargetArchPrompt');
    archPrompt.Type='text';
    archPrompt.Tag='archPrompt_tag';
    archPrompt.ToolTip=DAStudio.message('Simulink:taskEditor:TargetArchTip');

    archName.Name=hSrc.getActiveMappingFor('DistributedTarget').Architecture.Name;
    archName.Type='text';
    archName.Tag='archName_tag';
    archName.ToolTip=DAStudio.message('Simulink:taskEditor:TargetArchTip');

    archSelect.Name=DAStudio.message('Simulink:taskEditor:SelectPrompt');
    archSelect.ToolTip=DAStudio.message('Simulink:taskEditor:SelectTip');
    archSelect.Type='pushbutton';
    archSelect.Tag='archSelect_tag';
    archSelect.MatlabMethod='DeploymentDiagram.cba_setTemplateArchitecture';
    archSelect.MatlabArgs={hSrc.ParentDiagram};

    [indexedItems,layout]=...
    slprivate('getIndexedGroupItems',4,{...
    explicitMap,'stretch','stretch','stretch',...
    archPrompt,archName,'blank',archSelect...
    });
    stretch=[0,0,1,0];

    grp.Name=DAStudio.message('Simulink:taskEditor:ExplicitMappingGrp');
    grp.Type='group';
    grp.Items=indexedItems;
    grp.LayoutGrid=layout;
    grp.ColStretch=stretch;





    dlgItems={...
    descTxt,...
grp...
    };

    dlgStruct.DialogTitle='';
    dlgStruct.DisableDialog=DeploymentDiagram.isTaskConfigurationInUse(hSrc);
    dlgStruct.LayoutGrid=[4,1];
    dlgStruct.RowStretch=[0,0,0,1];
    dlgStruct.ColStretch=1;
    dlgStruct.Source=hSrc;
    dlgStruct.Items=dlgItems;
    dlgStruct.HelpMethod='helpview';
    mapId=['mapkey:',class(hSrc)];
    dlgStruct.HelpArgs={mapId,'help_button','CSHelpWindow'};
    dlgStruct.EmbeddedButtonSet={'Help'};


    function htm=configset_info_l(hSrc)
        if ismethod(hSrc,'getMCOSObjectReference')
            mcosObj=hSrc.getMCOSObjectReference();
        else
            mcosObj=hSrc;
        end
        model=mcosObj.ParentDiagram;
        helpLink=sprintf('helpview(''%s'', ''%s'');',strcat(docroot,'/mapfiles/simulink.map'),'mds_activate');
        helpToEnable=sprintf('<a href="matlab:%s">%s</a>',helpLink,DAStudio.message('Simulink:taskEditor:HelpToEnableConcurrency'));

        modelName=sprintf('<a href="matlab:%s">%s</a>',model,model);
        cs=getActiveConfigSet(model);
        callback=sprintf('cs = getActiveConfigSet(''%s'');cs.openDialog',model);
        conf=sprintf('<a href="matlab:%s">%s</a>',callback,cs.Name);

        if DeploymentDiagram.isConcurrentTasks(model)



            str=['<table width="100%%"  BORDER=0 CELLSPACING=0 CELLPADDING=0 bgcolor="#ededed">',...
            '<tr><td>',...
            '<b><font size=+1>%s</b></font>',...
            '<br><table><tr><td>%s</td></tr></table>',...
            '<br><table>',...
            '<tr><td align="right"><b>%s</b></td><td>%s</td></tr>',...
            '<tr><td align="right"><b>%s</b></td><td>%s</td></tr>',...
            '</table>',...
            '</td></tr>',...
            '</table>'];
            htm=sprintf(str,...
            DAStudio.message('Simulink:mds:ConfigComponentName'),...
            DAStudio.message('Simulink:taskEditor:TaskConfigurationDesc'),...
            DAStudio.message('Simulink:taskEditor:AssociatedModelPrompt'),modelName,...
            DAStudio.message('Simulink:taskEditor:AssociatedConfigurationPrompt'),conf);
        else

            isActiveStr='<font color="red"> (none)</font>';

            str=['<table width="100%%"  BORDER=0 CELLSPACING=0 CELLPADDING=0 bgcolor="#ededed">',...
            '<tr><td>',...
            '<b><font size=+1>%s</b></font>',...
            '<br><table><tr><td>%s</td></tr></table>',...
            '<br><table>',...
            '<tr><td align="right"><b>%s</b></td><td>%s</td></tr>',...
            '<tr><td align="right"><b>%s</b></td><td>%s</td></tr>',...
            '<tr><td align="right">%s</td></tr>',...
            '</table>',...
            '</td></tr>',...
            '</table>'];
            htm=sprintf(str,...
            DAStudio.message('Simulink:mds:ConfigComponentName'),...
            DAStudio.message('Simulink:taskEditor:TaskConfigurationDesc'),...
            DAStudio.message('Simulink:taskEditor:AssociatedModelPrompt'),modelName,...
            DAStudio.message('Simulink:taskEditor:AssociatedConfigurationPrompt'),isActiveStr,...
            helpToEnable);
        end


