function dlgStruct=cosimrefddg(source,h)


    switch h.BlockType
    case 'ObserverReference'
        mdlTagName=DAStudio.message('Simulink:Observer:ObserverRefModelName');
        objProperty='ObserverModelName';
        dialogTag='_Observer_Reference_Block_Tag_';
    case 'InjectorReference'
        mdlTagName=DAStudio.message('Simulink:Injector:InjectorRefModelName');
        objProperty='InjectorModelName';
        dialogTag='_Injector_Reference_Block_Tag_';
    end


    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name=h.BlockType;
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];


    contextMdlTag.Name=mdlTagName;
    contextMdlTag.Type='edit';
    contextMdlTag.RowSpan=[1,1];
    contextMdlTag.ColSpan=[1,1];
    contextMdlTag.ObjectProperty=objProperty;
    contextMdlTag.Tag=contextMdlTag.ObjectProperty;

    contextMdlTag.MatlabMethod='slDialogUtil';
    contextMdlTag.MatlabArgs={source,'sync','%dialog','edit','%tag'};

    openMdl.Name=DAStudio.message('Simulink:studio:ModelBlockOpenModelReference');
    openMdl.Type='pushbutton';
    openMdl.RowSpan=[1,1];
    openMdl.ColSpan=[2,2];
    openMdl.Tag='openModel';
    openMdl.MatlabMethod='cosimrefddg_cb';
    openMdl.MatlabArgs={source,'open'};
    openMdl.Visible=true;
    openMdl.Enabled=true;

    paramGrp.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGrp.Type='group';
    paramGrp.Items={contextMdlTag,openMdl};
    paramGrp.LayoutGrid=[2,2];
    paramGrp.RowSpan=[2,2];
    paramGrp.ColSpan=[1,1];
    paramGrp.Source=h;





    dlgStruct.DialogTitle=getString(message('Simulink:dialog:BlockParameters',strrep(h.Name,newline,' ')));
    dlgStruct.DialogTag=dialogTag;
    dlgStruct.Items={descGrp,paramGrp};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];


    dlgStruct.HelpMethod='cosimrefddg_cb';
    dlgStruct.HelpArgs={source,'help'};


    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};


    dlgStruct.PreApplyMethod='preApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};

    dlgStruct.PostApplyCallback='cosimrefddg_cb';
    dlgStruct.PostApplyArgs={source,'postApply','%dialog'};

    [~,isLocked]=source.isLibraryBlock(h);
    if isLocked||source.isHierarchySimulating
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end