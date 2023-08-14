function dlgStruct=getDialogSchema(hObj,unused)%#ok<INUSD>




    tplFileLbl.Type='text';
    tplFileLbl.Name=DAStudio.message('polyspace:gui:pslink:fileSelectorLabel');
    tplFileLbl.RowSpan=[1,1];
    tplFileLbl.ColSpan=[1,1];

    tplFileTxt.Type='edit';
    tplFileTxt.Source=hObj;
    tplFileTxt.ObjectProperty='selectedFile';
    tplFileTxt.RowSpan=[1,1];
    tplFileTxt.ColSpan=[2,5];
    tplFileTxt.Tag=['_pslink_',tplFileTxt.ObjectProperty,'_tag'];
    tplFileTxt.MinimumSize=[500,0];

    tplFilePush.Type='pushbutton';
    tplFilePush.Name=DAStudio.message('polyspace:gui:pslink:fileSelectorBrowser');
    tplFilePush.RowSpan=[1,1];
    tplFilePush.ColSpan=[6,6];
    tplFilePush.ToolTip=DAStudio.message('polyspace:gui:pslink:fileSelectorBrowserTooltip');
    tplFilePush.Tag='_pslink_file_selector_push_tag';
    tplFilePush.MatlabMethod='dialogCB';
    tplFilePush.MatlabArgs={hObj,'selectfile','%dialog'};

    panel.Type='group';
    panel.Name='';
    panel.LayoutGrid=[2,6];
    panel.RowSpan=[1,1];
    panel.ColSpan=[1,1];
    panel.RowStretch=[0,1];
    panel.ColStretch=[1,1,1,1,1,0];

    panel.Items={...
    tplFileLbl,tplFileTxt,tplFilePush,...
    };

    dlgStruct.DialogTitle=DAStudio.message('polyspace:gui:pslink:fileSelectorTitle');
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.Items={panel};
    dlgStruct.StandaloneButtonSet={'Ok','Cancel'};

    dlgStruct.CloseMethod='closeCB';
    dlgStruct.CloseMethodArgs={'%closeaction'};
    dlgStruct.CloseMethodArgsDT={'string'};
    dlgStruct.Sticky=true;