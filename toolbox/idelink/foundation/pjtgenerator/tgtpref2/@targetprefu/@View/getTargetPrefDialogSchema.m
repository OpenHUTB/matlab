function dlgstruct=getTargetPrefDialogSchema(hView,name)




    Data=hView.mController.getData();
    tagprefix='TargetPrefView_';

    idecontainer=getIDEDialogSchema(hView,Data,name);

    BoardSchema=getBoardDialogSchema(hView,Data,name);
    if(hView.mController.showMemory())
        MemorySchema=getMemoryDialogSchema(hView,Data,name);
    else
        MemorySchema={};
    end

    if(hView.mController.showSection())
        SectionSchema=getSectionDialogSchema(hView,Data,name);
    else
        SectionSchema={};
    end

    if(hView.mController.showPeripherals())
        PeripheralSchema=getPeripheralDialogSchema(hView,Data,name);
    else
        PeripheralSchema={};
    end

    if(hView.mController.showRTOS())
        RTOSSchema=getRTOSDialogSchema(hView,Data,name);
    else
        RTOSSchema={};
    end

    tabcontainer.Type='tab';
    tabcontainer.Tag=[tagprefix,'tab'];
    tabcontainer.Tabs={BoardSchema};
    if(~isempty(MemorySchema))
        tabcontainer.Tabs{end+1}=MemorySchema;
    end
    if(~isempty(SectionSchema))
        tabcontainer.Tabs{end+1}=SectionSchema;
    end
    if(~isempty(PeripheralSchema))
        tabcontainer.Tabs{end+1}=PeripheralSchema;
    end
    if(~isempty(RTOSSchema))
        tabcontainer.Tabs{end+1}=RTOSSchema;
    end
    tabcontainer.RowSpan=[2,2];
    tabcontainer.ColSpan=[1,2];
    tabcontainer.ActiveTab=hView.mCurTab;
    tabcontainer.TabChangedCallback='targetprefu.tabChangedCallback';

    spacer.Type='panel';
    spacer.RowSpan=[3,3];
    spacer.ColSpan=[1,2];


    dlgstruct.DialogTitle=hView.mController.getDisplayName();
    dlgstruct.DialogTag=name;
    dlgstruct.Items={idecontainer,tabcontainer,spacer};

    dlgstruct.Sticky=false;
    dlgstruct.LayoutGrid=[4,1];
    dlgstruct.RowStretch=[0,0,0,1];
    dlgstruct.CloseMethod='closeDialog';
    dlgstruct.CloseMethodArgs={'%dialog',dlgstruct.DialogTag};
    dlgstruct.CloseMethodArgsDT={'handle','mxArray'};
    dlgstruct.PreApplyMethod='validateEntries';
    dlgstruct.PreApplyArgs={'%dialog',dlgstruct.DialogTag};
    dlgstruct.PreApplyArgsDT={'handle','mxArray'};
    dlgstruct.PostApplyMethod='applyEntries';
    dlgstruct.PostApplyArgs={'%dialog',dlgstruct.DialogTag};
    dlgstruct.PostApplyArgsDT={'handle','mxArray'};
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs=hView.mController.getHelpArgs();
    dlgstruct.HelpArgsDT={'string','string'};
    dlgstruct.DisableDialog=hView.mController.isTargetPrefDlgDisbled();
