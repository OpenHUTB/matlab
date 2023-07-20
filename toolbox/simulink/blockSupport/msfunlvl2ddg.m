function dlgStruct=msfunlvl2ddg(source,h)




    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name=h.BlockType;
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];


    sfunName.Name=DAStudio.message('Simulink:dialog:SFuncName');
    sfunName.Type='edit';
    sfunName.RowSpan=[1,1];
    sfunName.ColSpan=[1,4];
    sfunName.ObjectProperty='FunctionName';
    sfunName.Tag=sfunName.ObjectProperty;
    sfunName.Enabled=~(source.isHierarchySimulating||...
    (Simulink.harness.internal.isHarnessCUT(h.Handle)&&...
    ~Simulink.harness.internal.isActiveHarnessCUTPropEditable(h.Handle)));

    sfunName.MatlabMethod='slDialogUtil';
    sfunName.MatlabArgs={source,'sync','%dialog','edit','%tag'};

    sfunNameEdit.Name=DAStudio.message('Simulink:dialog:Edit');
    sfunNameEdit.Type='pushbutton';
    sfunNameEdit.RowSpan=[1,1];
    sfunNameEdit.ColSpan=[5,5];
    sfunNameEdit.Tag='EditButtonTag';
    sfunNameEdit.Enabled=~(source.isHierarchySimulating||...
    (Simulink.harness.internal.isHarnessCUT(h.Handle)&&...
    ~Simulink.harness.internal.isActiveHarnessCUTPropEditable(h.Handle)));
    sfunNameEdit.MatlabMethod='sfunddg_cb';
    sfunNameEdit.MatlabArgs={'%dialog','%source','%tag'};

    paramParams.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramParams.Type='edit';
    paramParams.RowSpan=[2,2];
    paramParams.ColSpan=[1,5];
    paramParams.ObjectProperty='Parameters';
    paramParams.Tag=paramParams.ObjectProperty;

    paramParams.MatlabMethod='slDialogUtil';
    paramParams.MatlabArgs={source,'sync','%dialog','edit','%tag'};

    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[3,3];
    spacer.ColSpan=[1,5];

    paramGrp.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGrp.Type='group';
    paramGrp.Items={sfunName,sfunNameEdit,paramParams,spacer};

    paramGrp.LayoutGrid=[3,5];
    paramGrp.ColStretch=[1,1,1,1,0];
    paramGrp.RowStretch=[0,0,1];
    paramGrp.RowSpan=[2,2];
    paramGrp.ColSpan=[1,1];
    paramGrp.Source=h;




    dlgStruct.DialogTitle=DAStudio.message('Simulink:dialog:BlockParameters',strrep(h.Name,sprintf('\n'),' '));
    dlgStruct.DialogTag='MATLAB S-Function';
    dlgStruct.Items={descGrp,paramGrp};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};

    dlgStruct.PreApplyMethod='preApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};

    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

    [~,isLocked]=source.isLibraryBlock(h);
    if isLocked
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end

