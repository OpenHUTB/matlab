function dlgStruct=getDialogSchema(this,unused)%#ok<INUSD>




    fileList.Name=pslinkprivate('pslinkMessage','get','pslink:GUIfileList');
    fileList.Type='listbox';
    fileList.UserData=this.AdditionalFileList;
    fileList.Entries=fileList.UserData;
    fileList.Tag='_pslink_additional_files_list_tag';
    fileList.RowSpan=[1,5];
    fileList.ColSpan=[1,9];
    fileList.Mode=1;
    fileList.DialogRefresh=1;
    fileList.Source=this;
    fileList.MinimumSize=[600,300];

    addPush.Type='pushbutton';
    addPush.Name=pslinkprivate('pslinkMessage','get','pslink:GUIfileListAddPush');
    addPush.RowSpan=[2,2];
    addPush.ColSpan=[1,1];
    addPush.Tag='_pslink_Add';
    addPush.MatlabMethod='dialogCB';
    addPush.MatlabArgs={this,'addfile','%dialog'};

    removePush.Type='pushbutton';
    removePush.Name=pslinkprivate('pslinkMessage','get','pslink:GUIfileListRemovePush');
    removePush.RowSpan=[3,3];
    removePush.ColSpan=[1,1];
    removePush.Tag='_pslink_Remove';
    removePush.MatlabMethod='dialogCB';
    removePush.MatlabArgs={this,'removefile','%dialog'};

    removeAllPush.Type='pushbutton';
    removeAllPush.Name=pslinkprivate('pslinkMessage','get','pslink:GUIfileListRemoveAllPush');
    removeAllPush.RowSpan=[4,4];
    removeAllPush.ColSpan=[1,1];
    removeAllPush.Tag='_pslink_Remove_all';
    removeAllPush.MatlabMethod='dialogCB';
    removeAllPush.MatlabArgs={this,'removeallfiles','%dialog'};

    pushPanel.Type='panel';
    pushPanel.Items={addPush,removePush,removeAllPush};
    pushPanel.RowSpan=[1,5];
    pushPanel.ColSpan=[10,11];
    pushPanel.LayoutGrid=[5,1];
    pushPanel.RowStretch=[1,0,0,0,1];

    dlgStruct.DialogTitle=pslinkprivate('pslinkMessage','get','pslink:GUIfileListDialogTitle');
    dlgStruct.Items={fileList,pushPanel};
    dlgStruct.LayoutGrid=[6,12];
    dlgStruct.RowStretch=[1,0,0,0,0,0];
    dlgStruct.ColStretch=[1,0,0,0,0,0,0,0,0,0,0,0];
    dlgStruct.StandaloneButtonSet={'Ok','Cancel'};

    dlgStruct.CloseMethod='closeCB';
    dlgStruct.CloseMethodArgs={'%closeaction'};
    dlgStruct.CloseMethodArgsDT={'string'};
    dlgStruct.Sticky=true;


