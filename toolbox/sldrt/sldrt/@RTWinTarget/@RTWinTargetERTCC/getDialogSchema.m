function dlgstruct=getDialogSchema(hSrc,schemaName)






    unsuptags={...
    'Tag_ConfigSet_RTW_ERT_MatFileLogging',...
'Tag_ConfigSet_RTW_ERT_LogVarNameModifier'...
    };
    unsupgroups={...
    DAStudio.message('RTW:configSet:ERTDialogDataExchangeName'),...
    };
    interfaceTab=RTWinTarget.RTWinTargetCC.removeFromItems(getInterfaceDialog(hSrc,schemaName),unsuptags,unsupgroups);


    codeStyleTab=getCodeStyleDialog(hSrc,schemaName);


    unsuptags={...
    'Tag_ConfigSet_RTW_Templates_GenerateSampleERTMain',...
    'Tag_ConfigSet_RTW_Templates_TargetOSLbl',...
'Tag_ConfigSet_RTW_Templates_TargetOS'...
    };
    templateTab=RTWinTarget.RTWinTargetCC.removeFromItems(getTemplateDialog(hSrc,schemaName),unsuptags,{});


    dataPlacementTab=getDataPlacementDialog(hSrc,schemaName);


    replacementTab=getReplacementDialog(hSrc,schemaName);


    internalMemorySectionTab=getInternalMemorySectionDialog(hSrc,schemaName);

    tag='Tag_ConfigSet_Target_RTWIN_';






    widget.Name=getString(message('sldrt:ccdialog:generateassembly'));
    widget.Type='checkbox';
    widget.ObjectProperty='CCListing';
    widget.Mode=1;
    widget.Enabled=double(~hSrc.isReadonlyProperty(widget.ObjectProperty));
    widget.Tag=[tag,widget.ObjectProperty];
    widget.ToolTip=getString(message('sldrt:ccdialog:generateassemblytip'));
    ccList=widget;
    clear widget;

    widget.Name=getString(message('sldrt:ccdialog:rebuildall'));
    widget.Type='checkbox';
    widget.ObjectProperty='RebuildAll';
    widget.Mode=1;
    widget.Enabled=double(~hSrc.isReadonlyProperty(widget.ObjectProperty));
    widget.Tag=[tag,widget.ObjectProperty];
    widget.ToolTip=getString(message('sldrt:ccdialog:rebuildalltip'));
    rebuildAll=widget;
    clear widget;







    group.Name=getString(message('sldrt:ccdialog:groupname'));
    group.Type='group';
    group.Items={ccList,rebuildAll};
    target=group;
    target.RowSpan=[1,1];
    clear group;


    unsupgroups={...
    };
    unsupitems={...
    'Tag_ConfigSet_Target_ExtModeStaticAlloc',...
    'Tag_ConfigSet_Target_ExtModeStaticAllocSize',...
    };
    extModeGroup=RTWinTarget.RTWinTargetCC.removeFromItems(getExtModeOptionDialog(hSrc,'group'),unsupitems,unsupgroups);
    extModeGroup.Items{1}.Enabled=0;
    extModeGroup.RowSpan=[2,2];

    sldrttitle='Simulink Desktop Real-Time';
    panel.Name=sldrttitle;
    panel.Items={target,extModeGroup};
    panel.LayoutGrid=[4,1];
    panel.RowStretch=[0,0,0,1];
    panel.Tag='Tag_ConfigSet_RTW_Real_Time_Windows_Target';


    if strcmp(schemaName,'tab')
        dlgstruct.Tabs={interfaceTab,codeStyleTab,templateTab,dataPlacementTab,replacementTab,internalMemorySectionTab,panel};
        dlgstruct.nTabs=numel(dlgstruct.Tabs);
    else
        dlgstruct.DialogTitle=sldrttitle;
        dlgstruct.Items={panel};
    end

end
