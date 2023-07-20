function dlgstruct=getDialogSchema(hUI,schemaName)%#ok




    packageSelGrp=getSchema_packageSelGrp(hUI);
    mainTabs=getSchema_mainTabs(hUI);
    saveGrp=getSchema_saveGrp(hUI);
    validGrp=getSchema_validGrp(hUI);
    previewGrp=getSchema_previewGrp(hUI);


    dlgstruct.DialogTitle=DAStudio.message('Simulink:dialog:CSCDesignerTitle');
    if hUI.IsDirty
        dlgstruct.DialogTitle=[dlgstruct.DialogTitle,' *'];
    end
    dlgstruct.LayoutGrid=[6,5];
    dlgstruct.RowStretch=[0,1,1,1,1,0];
    dlgstruct.ColStretch=[1,1,1,2,2];

    packageSelGrp.RowSpan=[1,1];
    packageSelGrp.ColSpan=[1,3];
    mainTabs.RowSpan=[2,5];
    mainTabs.ColSpan=[1,3];
    saveGrp.RowSpan=[6,6];
    saveGrp.ColSpan=[1,3];
    validGrp.RowSpan=[1,2];
    validGrp.ColSpan=[4,5];
    previewGrp.RowSpan=[3,6];
    previewGrp.ColSpan=[4,5];

    dlgstruct.DialogTag='Tag_CSCUI';

    dlgstruct.Items={packageSelGrp,mainTabs,saveGrp,validGrp,previewGrp};
    dlgstruct.DefaultOk=false;

    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/toolbox/ecoder/helptargets.map'],'ert_CSC_chapter'};

    dlgstruct.CloseMethod='promptSave';
    dlgstruct.CloseMethodArgs={'%closeaction'};
    dlgstruct.CloseMethodArgsDT={'string'};






