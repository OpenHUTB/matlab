function dlgStruct=fromddg(source,h)




    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name=h.BlockType;
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];


    gotoTag.Name=DAStudio.message('Simulink:blkprm_prompts:FromGotoTag');
    gotoTag.Type='combobox';
    gotoTag.Entries=gotoddg_cb(source,'getGotoTagEntries',h)';
    gotoTag.Editable=1;
    gotoTag.RowSpan=[1,1];
    gotoTag.ColSpan=[1,4];
    gotoTag.ObjectProperty='GotoTag';
    gotoTag.Tag=gotoTag.ObjectProperty;
    gotoTag.MatlabMethod='gotoddg_cb';
    gotoTag.MatlabArgs={source,'doGotoTagSelection','%dialog','%tag'};

    gotoBlockLbl.Name=DAStudio.message('Simulink:blkprm_prompts:Gotosource');
    gotoBlockLbl.Type='text';
    gotoBlockLbl.RowSpan=[2,2];
    gotoBlockLbl.ColSpan=[1,1];
    if isempty(h.GotoBlock.name)
        gotoBlock.Name='none';
        gotoBlock.Type='text';
        gotoBlock.Italic=1;
    else
        [name,args]=gotoddg_cb(source,'getGotoURL');
        gotoBlock.Name=name;
        gotoBlock.Type='hyperlink';
        gotoBlock.MatlabMethod='gotoddg_cb';
        gotoBlock.MatlabArgs=[{source},{'hilite'},args(:)'];
    end
    gotoBlock.RowSpan=[2,2];
    gotoBlock.ColSpan=[2,5];

    gotoIcon.Name=DAStudio.message('Simulink:blkprm_prompts:IconDisplay');
    gotoIcon.Type='combobox';
    gotoIcon.Entries=h.getPropAllowedValues('IconDisplay',true)';
    gotoIcon.RowSpan=[3,3];
    gotoIcon.ColSpan=[1,5];
    gotoIcon.ObjectProperty='IconDisplay';
    gotoIcon.Tag=gotoIcon.ObjectProperty;

    gotoIcon.MatlabMethod='slDialogUtil';
    gotoIcon.MatlabArgs={source,'sync','%dialog','combobox','%tag'};

    fromRefresh.Name=DAStudio.message('Simulink:blkprm_prompts:UpdateTags');
    fromRefresh.Type='pushbutton';
    fromRefresh.RowSpan=[1,1];
    fromRefresh.ColSpan=[5,5];
    fromRefresh.Tag='fromRefresh';
    fromRefresh.MatlabMethod='gotoddg_cb';
    fromRefresh.MatlabArgs={source,'refreshTags','%dialog','%tag'};

    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[4,4];
    spacer.ColSpan=[1,2];

    paramGrp.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGrp.Type='group';
    paramGrp.Items={gotoTag,fromRefresh,gotoBlockLbl,gotoBlock,gotoIcon,spacer};
    paramGrp.LayoutGrid=[4,2];
    paramGrp.RowStretch=[0,0,0,1];
    paramGrp.ColStretch=[0,1];
    paramGrp.RowSpan=[2,2];
    paramGrp.ColSpan=[1,1];
    paramGrp.Source=h;




    dlgStruct.DialogTitle=getString(message('Simulink:dialog:BlockParameters',strrep(h.Name,sprintf('\n'),' ')));
    dlgStruct.DialogTag='From';
    dlgStruct.Items={descGrp,paramGrp};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];
    dlgStruct.CloseCallback='gotoddg_cb';
    dlgStruct.CloseArgs={source,'unhilite','%dialog'};
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};

    dlgStruct.PreApplyCallback='gotoddg_cb';
    dlgStruct.PreApplyArgs={source,'doPreApply','%dialog'};

    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

    [isLib,isLocked]=source.isLibraryBlock(h);
    if isLocked||source.isHierarchySimulating
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end
