function dlgstruct=slimmodelinfoddg(h,name)




    spacerH=5;

    spacerTextTop.Name='';
    spacerTextTop.Type='text';
    spacerTextTop.MaximumSize=[-1,spacerH];
    spacerTextTop.RowSpan=[1,1];


    lastByValLbl.Name=DAStudio.message('Simulink:dialog:ModelLastByValLblName');
    lastByValLbl.Type='text';
    lastByValLbl.RowSpan=[2,2];
    lastByValLbl.ColSpan=[1,1];

    lastByVal.Name=h.LastModifiedBy;
    lastByVal.Tag='LastModifiedBy';
    lastByVal.Type='text';
    lastByVal.RowSpan=[2,2];
    lastByVal.ColSpan=[2,2];



    lastOnVerValLbl.Name=DAStudio.message('Simulink:dialog:ModelLastOnVerValLblName');
    lastOnVerValLbl.Type='text';
    lastOnVerValLbl.RowSpan=[3,3];
    lastOnVerValLbl.ColSpan=[1,1];

    lastOnVerVal.Name=h.LastModifiedDate;
    lastOnVerVal.Tag='LastModifiedDate';
    lastOnVerVal.Type='text';
    lastOnVerVal.RowSpan=[3,3];
    lastOnVerVal.ColSpan=[2,2];

    spacerTextBottom.Name='';
    spacerTextBottom.Type='text';
    spacerTextBottom.MaximumSize=[-1,spacerH];
    spacerTextBottom.RowSpan=[4,4];

    topSection.Type='panel';
    topSection.Items={spacerTextTop,lastByValLbl,lastByVal,lastOnVerValLbl,lastOnVerVal,spacerTextBottom};
    topSection.LayoutGrid=[4,2];
    topSection.ColStretch=[0,1];
    topSection.RowSpan=[1,1];
    topSection.ColSpan=[1,1];


    descriptionEditArea.Type='editarea';
    descriptionEditArea.Tag='Description';
    descriptionEditArea.ToolTip=DAStudio.message('Simulink:dialog:EnterTextHere');
    descriptionEditArea.ObjectProperty='Description';
    descriptionEditArea.MatlabMethod='defaultModelPropCB_ddg';
    descriptionEditArea.MatlabArgs={'%dialog','%source','%tag','%value'};
    descriptionEditArea.PreferredSize=[150,50];
    descriptionEditArea.WordWrap=true;
    descriptionEditArea.RowSpan=[1,1];
    descriptionEditArea.ColSpan=[1,2];


    descriptionTogglePanel.Name=DAStudio.message('Simulink:dialog:ModelTabFiveName');
    descriptionTogglePanel.Type='togglepanel';
    descriptionTogglePanel.Tag='DesciiptionTag';
    descriptionTogglePanel.Items={descriptionEditArea};
    descriptionTogglePanel.RowSpan=[2,2];
    descriptionTogglePanel.ColSpan=[1,1];






    readOnly.Name=DAStudio.message('Simulink:dialog:ModelReadOnlyName');
    readOnly.Tag='EditVersionInfo';
    readOnly.Type='checkbox';
    readOnly.Graphical=1;
    readOnly.DialogRefresh=true;
    readOnly.MatlabMethod='modelddg_cb';
    readOnly.MatlabArgs={'%dialog','doReadOnly',h,'%value'};
    if(strcmp(h.EditVersionInfo,'ViewCurrentValues'))
        readOnly.Value=1;
    else
        readOnly.Value=0;
    end

    editMode=~readOnly.Value;
    if(strcmp(h.BlockDiagramType,'library')&&strcmp(h.Lock,'on'))
        editMode=0;
        readOnly.Enabled=false;
    end

    readOnly.RowSpan=[4,4];
    readOnly.ColSpan=[1,1];


    modelVerValLbl.Name=DAStudio.message('Simulink:dialog:ModelModelVerValLblName');
    modelVerValLbl.Type='text';
    modelVerValLbl.RowSpan=[1,1];
    modelVerValLbl.ColSpan=[1,1];

    modelVerVal.Name=h.ModelVersion;
    modelVerVal.Tag='ModelVersion';
    modelVerVal.Type='text';
    modelVerVal.RowSpan=[1,1];
    modelVerVal.ColSpan=[2,2];



    creatorEditLbl.Name=DAStudio.message('Simulink:dialog:ModelCreatorEditLblName');
    creatorEditLbl.Type='text';
    creatorEditLbl.RowSpan=[2,2];
    creatorEditLbl.ColSpan=[1,1];

    creatorEdit.Name='';
    creatorEdit.Tag='Creator';
    creatorEdit.Type='edit';
    creatorEdit.ObjectProperty=creatorEdit.Tag;
    creatorEdit.RowSpan=[2,2];
    creatorEdit.ColSpan=[2,2];
    creatorEdit.Enabled=editMode;
    creatorEdit.MatlabMethod='defaultModelPropCB_ddg';
    creatorEdit.MatlabArgs={'%dialog','%source','%tag','%value'};


    createdEditLbl.Name=DAStudio.message('Simulink:dialog:ModelCreatedEditLblName');
    createdEditLbl.Type='text';
    createdEditLbl.RowSpan=[3,3];
    createdEditLbl.ColSpan=[1,1];

    createdEdit.Name='';
    createdEdit.Tag='Created';
    createdEdit.Type='edit';
    createdEdit.ObjectProperty=createdEdit.Tag;
    createdEdit.RowSpan=[3,3];
    createdEdit.ColSpan=[2,2];
    createdEdit.Enabled=editMode;
    createdEdit.MatlabMethod='defaultModelPropCB_ddg';
    createdEdit.MatlabArgs={'%dialog','%source','%tag','%value'};


    modelInfoGroup.Name=DAStudio.message('Simulink:dialog:ModelVersionName');
    modelInfoGroup.Type='togglepanel';
    modelInfoGroup.LayoutGrid=[4,2];
    modelInfoGroup.ColStretch=[0,1];
    modelInfoGroup.RowSpan=[3,3];
    modelInfoGroup.ColSpan=[1,1];
    modelInfoGroup.Flat=true;
    modelInfoGroup.Items={modelVerValLbl,modelVerVal,creatorEditLbl,creatorEdit,...
    createdEditLbl,createdEdit,readOnly};


    instruction.Name=DAStudio.message('Simulink:dialog:ModelInspectorInstruction');
    instruction.Type='text';
    instruction.WordWrap=true;
    instruction.PreferredSize=[-1,80];
    instruction.MaximumSize=[-1,100];

    spacer.Type='panel';

    instructionPanel.Type='panel';
    instructionPanel.Items={instruction,spacer};
    instructionPanel.RowSpan=[4,5];
    instructionPanel.ColSpan=[1,1];




    if slreq.utils.isInPerspective(h.Handle)

        linkInfoPanel=slreq.gui.slimInfoDDG(h.Handle);
        linkInfoPanel.RowSpan=[4,4];
        linkInfoPanel.ColSpan=[1,1];
        instructionPanel.RowSpan=[5,5];
    else
        linkInfoPanel=struct('Type','panel');
    end




    dlgstruct.DialogTitle='';
    dlgstruct.DialogTag=name;
    dlgstruct.DialogMode='Slim';
    dlgstruct.Items={topSection,descriptionTogglePanel,modelInfoGroup,instructionPanel,linkInfoPanel};
    dlgstruct.LayoutGrid=[5,1];
    dlgstruct.RowStretch=[0,0,0,0,1];
    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.EmbeddedButtonSet={''};
end









