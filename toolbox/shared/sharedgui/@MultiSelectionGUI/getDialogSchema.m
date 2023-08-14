function hDlg=getDialogSchema(hObj)




    descr.Name=DAStudio.message(hObj.itemNamesAndDescription.Description);
    descr.Type='text';
    descr.ColSpan=[1,2];
    descr.RowSpan=[1,2];

    descrGrp.Type='group';
    descrGrp.Name=DAStudio.message(hObj.itemNamesAndDescription.GroupName);
    descrGrp.Items={descr};
    descrGrp.RowSpan=[1,1];
    descrGrp.ColSpan=[1,1];

    contentSchema=getContentDialogSchema(hObj);
    contentGrp.Type='group';
    contentGrp.LayoutGrid=[9,3];
    contentGrp.Items=contentSchema.Items;
    contentGrp.RowSpan=[2,2];
    contentGrp.ColSpan=[1,1];
    contentGrp.Enabled=true;


    infoBrowser.Type='webbrowser';
    infoBrowser.Tag='infoBrowser';
    infoBrowser.HTML=hObj.highlightObjDescription;
    infoBrowser.ColSpan=[1,2];
    infoBrowser.RowSpan=[1,2];
    infoBrowser.DialogRefresh=1;

    infoGrp.Type='group';
    infoGrp.Name='Details';
    infoGrp.Items={infoBrowser};
    infoGrp.RowSpan=[3,3];
    infoGrp.ColSpan=[1,1];



    contentsLGrp.LayoutGrid=[3,1];
    contentsLGrp.Type='panel';
    contentsLGrp.Items={descrGrp,contentGrp,infoGrp};


    hDlg.DialogTitle=DAStudio.message(hObj.itemNamesAndDescription.DialogTitle);
    hDlg.LayoutGrid=[3,1];
    hDlg.Items={contentsLGrp};
    hDlg.StandaloneButtonSet={'OK','Cancel','Help'};
    hDlg.PostApplyMethod='postApplyCallBack';
    hDlg.HelpMethod='helpview';
    hDlg.HelpArgs={hObj.helpDocLocation,hObj.configsetTag};
    hDlg.Sticky=true;
end


