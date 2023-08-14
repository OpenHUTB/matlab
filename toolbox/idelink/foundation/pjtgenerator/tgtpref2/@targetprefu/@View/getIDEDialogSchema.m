function dlgstruct=getIDEDialogSchema(hView,data,name)%#ok<INUSD>




    tagprefix='TargetPrefIDE_';

    IDEListLabel.Name=hView.mLabels.IDE.IDEName;
    IDEListLabel.Type='text';
    IDEListLabel.RowSpan=[1,1];
    IDEListLabel.ColSpan=[1,1];
    IDEListLabel.Buddy=[tagprefix,'IDEList'];

    IDEList.Type='combobox';
    IDEList.Entries=data.getAdaptorNameList();
    IDEList.Entries=[IDEList.Entries,{'Get more...'}];
    IDEList.Value=data.getCurAdaptorName();
    IDEList.Tag=[tagprefix,'IDEList'];
    IDEList.ToolTip=hView.mToolTips.IDE.IDEName;
    IDEList.RowSpan=[1,1];
    IDEList.ColSpan=[2,2];


    IDEList.Mode=true;
    IDEList.DialogRefresh=true;
    IDEList.Enabled=~hView.mController.isTargetPrefDlgDisbled();
    IDEList=hView.addControllerCallBack(IDEList,'setIDE','%value');

    IDESchemaItems.Type='panel';
    IDESchemaItems.Tag=[tagprefix,'panel'];
    IDESchemaItems.LayoutGrid=[2,2];
    IDESchemaItems.RowStretch=[0,1];
    IDESchemaItems.ColStretch=[0,1];
    IDESchemaItems.Items={IDEListLabel,IDEList};

    dlgstruct=IDESchemaItems;
