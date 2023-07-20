function dlgStruct=gotoddg(source,h)




    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name=h.BlockType;
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];


    gotoTag.Name=DAStudio.message('Simulink:blkprm_prompts:FromGotoTag');
    gotoTag.Type='edit';
    gotoTag.RowSpan=[1,1];
    gotoTag.ColSpan=[1,1];
    gotoTag.ObjectProperty='GotoTag';
    gotoTag.Tag=gotoTag.ObjectProperty;

    gotoTag.MatlabMethod='slDialogUtil';
    gotoTag.MatlabArgs={source,'sync','%dialog','edit','%tag'};

    renameAll.Name=DAStudio.message('Simulink:studio:RenameAll');
    renameAll.Type='pushbutton';
    renameAll.ToolTip=DAStudio.message('Simulink:studio:UpdateAllBlocks');
    renameAll.RowSpan=[1,1];
    renameAll.ColSpan=[2,2];
    renameAll.Tag='renameAll';
    renameAll.MatlabMethod='SLStudio.RenameGotoTagDialog.launch';
    renameAll.MatlabArgs={source};
    renameAll.Visible=true;
    renameAll.Enabled=~(isempty(h.FromBlocks)&&isempty(h.TagVisibilityBlock));

    gotoVis.Name=DAStudio.message('Simulink:blkprm_prompts:GotoTagVis');
    gotoVis.Type='combobox';
    gotoVis.Entries=h.getPropAllowedValues('TagVisibility',true)';
    gotoVis.RowSpan=[1,1];
    gotoVis.ColSpan=[3,3];
    gotoVis.ObjectProperty='TagVisibility';
    gotoVis.Tag=gotoVis.ObjectProperty;

    gotoVis.MatlabMethod='slDialogUtil';
    gotoVis.MatlabArgs={source,'sync','%dialog','combobox','%tag'};

    gotoFrom.Name=DAStudio.message('Simulink:dialog:GotoBlockCorrespondingBlocks');
    gotoFrom.Type='textbrowser';
    gotoFrom.Text=gotoddg_cb(source,'getFromHTML');
    gotoFrom.RowSpan=[2,2];
    gotoFrom.ColSpan=[1,3];
    gotoFrom.Tag='gotoFrom';

    gotoIcon.Name=DAStudio.message('Simulink:blkprm_prompts:IconDisplay');
    gotoIcon.Type='combobox';
    gotoIcon.Entries=h.getPropAllowedValues('IconDisplay',true)';
    gotoIcon.RowSpan=[3,3];
    gotoIcon.ColSpan=[1,3];
    gotoIcon.ObjectProperty='IconDisplay';
    gotoIcon.Tag=gotoIcon.ObjectProperty;

    gotoIcon.MatlabMethod='slDialogUtil';
    gotoIcon.MatlabArgs={source,'sync','%dialog','combobox','%tag'};


    paramGrp.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGrp.Type='group';
    paramGrp.Items={gotoTag,gotoVis,renameAll,gotoFrom,gotoIcon};
    paramGrp.LayoutGrid=[3,3];
    paramGrp.RowStretch=[0,1,0];
    paramGrp.RowSpan=[2,2];
    paramGrp.ColSpan=[1,1];
    paramGrp.Source=h;





    dlgStruct.DialogTitle=getString(message('Simulink:dialog:BlockParameters',strrep(h.Name,sprintf('\n'),' ')));
    dlgStruct.DialogTag='Goto';
    dlgStruct.Items={descGrp,paramGrp};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];
    dlgStruct.CloseCallback='gotoddg_cb';
    dlgStruct.CloseArgs={source,'unhilite'};
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};

    dlgStruct.PreApplyMethod='preApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};
    dlgStruct.PostApplyCallback='gotoddg_cb';
    dlgStruct.PostApplyArgs={source,'postApply'};

    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

    [~,isLocked]=source.isLibraryBlock(h);
    if isLocked||source.isHierarchySimulating
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end
