function dlgstruct=getDialogSchema(hSrc,schemaName)





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







    sfEnv=hSrc.getCommonOptionDialog('group');


    for i=1:length(sfEnv.Items{1}.Items)
        if strcmp(sfEnv.Items{1}.Items{i}.Tag,'Tag_ConfigSet_RTW_Target_CodeReplacementLibrary')
            sfEnv.Items{1}.Items{i}.Entries(strncmp(sfEnv.Items{1}.Items{i}.Entries,'Intel IPP',9))=[];
        end
    end


    group.Name=getString(message('sldrt:ccdialog:groupname'));
    group.Type='group';
    group.Items={ccList,rebuildAll};
    target=group;
    clear group;


    unsupgroups={...
    };
    unsupitems={...
    'Tag_ConfigSet_Target_ExtModeStaticAlloc',...
    'Tag_ConfigSet_Target_ExtModeStaticAllocSize',...
    };
    extModeGroup=RTWinTarget.RTWinTargetCC.removeFromItems(getExtModeOptionDialog(hSrc,'group'),unsupitems,unsupgroups);
    extModeGroup.Items{1}.Enabled=0;

    sfEnv.RowSpan=[1,1];
    target.RowSpan=[2,2];
    extModeGroup.RowSpan=[3,3];
    panel.Name='';
    panel.Type='panel';
    panel.Items={sfEnv,target,extModeGroup};
    panel.LayoutGrid=[4,1];
    panel.RowStretch=[0,0,0,1];
    panel.Tag='Tag_ConfigSet_RTW_Real_Time_Windows_Target';

    sldrttitle='Simulink Desktop Real-Time';


    if strcmp(schemaName,'tab')
        dlgstruct.Name=sldrttitle;
    else
        dlgstruct.DialogTitle=sldrttitle;
    end
    dlgstruct.Items={panel};

end
