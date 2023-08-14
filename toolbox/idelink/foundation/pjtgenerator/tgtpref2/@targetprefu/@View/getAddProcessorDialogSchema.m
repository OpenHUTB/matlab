function dlgstruct=getAddProcessorDialogSchema(hView,name)





    tagprefix='AddProcessor_';

    NewProcNameLabel.Name=hView.mLabels.Board.NewProcName;
    NewProcNameLabel.Type='text';
    NewProcNameLabel.RowSpan=[1,1];
    NewProcNameLabel.ColSpan=[1,1];

    NewProcName.Type='edit';
    NewProcName.Value=hView.mController.getAddProcessorNewName();
    NewProcName.Tag=[tagprefix,'NewProcName'];
    NewProcName.ToolTip=hView.mToolTips.Board.NewProcName;
    NewProcName.DialogRefresh=false;
    NewProcName.RowSpan=[1,1];
    NewProcName.ColSpan=[2,2];
    NewProcName=hView.addControllerCallBack(NewProcName,'setAddProcessorNewName','%value');

    BasedOnLabel.Name=hView.mLabels.Board.BasedOn;
    BasedOnLabel.Type='text';
    BasedOnLabel.RowSpan=[2,2];
    BasedOnLabel.ColSpan=[1,1];

    BasedOn.Type='combobox';
    BasedOn.Entries=hView.mController.getAddProcessorNameList();
    BasedOn.Value=hView.mController.getAddProcessorBasedOn();
    BasedOn.Tag=[tagprefix,'BasedOn'];
    BasedOn.ToolTip=hView.mToolTips.Board.BasedOn;
    BasedOn.DialogRefresh=false;
    BasedOn.Enabled=false;
    BasedOn.Bold=true;
    BasedOn.RowSpan=[2,2];
    BasedOn.ColSpan=[2,2];
    BasedOn=hView.addControllerCallBack(BasedOn,'setAddProcessorBasedOn','%value');

    CompilerOptionLabel.Name=hView.mLabels.BoardSupport.CompilerOptions;
    CompilerOptionLabel.Type='text';
    CompilerOptionLabel.RowSpan=[3,3];
    CompilerOptionLabel.ColSpan=[1,1];

    CompilerOption.Type='edit';
    CompilerOption.Tag=[tagprefix,'CompilerOption'];
    CompilerOption.Value=hView.mController.getAddProcessorCompilerOption();
    CompilerOption.RowSpan=[3,3];
    CompilerOption.ColSpan=[2,2];
    CompilerOption.DialogRefresh=false;
    CompilerOption=hView.addControllerCallBack(CompilerOption,'setAddProcessorCompilerOption','%value');

    LinkerOptionLabel.Name=hView.mLabels.BoardSupport.LinkerOptions;
    LinkerOptionLabel.Type='text';
    LinkerOptionLabel.RowSpan=[4,4];
    LinkerOptionLabel.ColSpan=[1,1];

    LinkerOption.Type='edit';
    LinkerOption.Tag=[tagprefix,'LinkerOption'];
    LinkerOption.Value=hView.mController.getAddProcessorLinkerOption();
    LinkerOption.RowSpan=[4,4];
    LinkerOption.ColSpan=[2,2];
    LinkerOption.DialogRefresh=false;
    LinkerOption=hView.addControllerCallBack(LinkerOption,'setAddProcessorLinkerOption','%value');

    spacer.Type='panel';
    spacer.RowSpan=[5,5];
    spacer.ColSpan=[1,2];

    dlgstruct.DialogTitle=hView.mController.getAddProcessorTitle();
    dlgstruct.DialogTag=name;
    dlgstruct.StandaloneButtonSet={'OK','Cancel'};
    dlgstruct.Sticky=true;
    dlgstruct.Items={NewProcNameLabel,NewProcName,...
    BasedOnLabel,BasedOn,...
    CompilerOptionLabel,CompilerOption,...
    LinkerOptionLabel,LinkerOption,...
    spacer};
    dlgstruct.LayoutGrid=[5,2];
    dlgstruct.RowStretch=[0,0,0,0,1];
    dlgstruct.ColStretch=[0,1];
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
