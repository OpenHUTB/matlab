function dlgstruct=getDialogSchema(this,schemaName)




    IsSaveDlg=this.IsSaveDlg;




    if strncmp(this.MAObj.TaskAdvisorRoot.ID,'com.mathworks.FPCA.',19)
        if IsSaveDlg
            title=[DAStudio.message('SimulinkFixedPoint:fpca:SaveRestorepointDialogTitle'),' - ',getfullname(this.MAObj.System)];
        else
            title=[DAStudio.message('SimulinkFixedPoint:fpca:LoadRestorepointDialogTitle'),' - ',getfullname(this.MAObj.System)];
        end
    elseif strncmp(this.MAObj.TaskAdvisorRoot.ID,'com.mathworks.HDL.',18)
        if IsSaveDlg
            title=[DAStudio.message('HDLShared:hdldialog:HDLWASaveRestorePointDialogTitle'),' - ',getfullname(this.MAObj.System)];
        else
            title=[DAStudio.message('HDLShared:hdldialog:HDLWALoadRestorePointDialogTitle'),' - ',getfullname(this.MAObj.System)];
        end
    else
        if IsSaveDlg
            title=[DAStudio.message('Simulink:tools:MAMASaveRestorepointDialogTitle'),' - ',getfullname(this.MAObj.System)];
        else
            title=[DAStudio.message('Simulink:tools:MAMALoadRestorepointDialogTitle'),' - ',getfullname(this.MAObj.System)];
        end
    end

    if IsSaveDlg
        mytable.Name=DAStudio.message('Simulink:tools:MASaveRestorepointInstruct');
    else
        mytable.Name=DAStudio.message('Simulink:tools:MALoadRestorepointInstruct');
    end
    mytable.Type='table';
    mytable.Tag='mytable_list';
    mytable.Editable=false;
    mytable.Data={};
    mytable.SelectedRow=0;
    if isa(this.MAObj,'Simulink.ModelAdvisor')
        shlist=this.MAObj.getRestorePointList;
        for i=1:length(shlist)
            shname=shlist{i}.name;
            shdescription=shlist{i}.description;
            shtime=datestr(shlist{i}.timestamp);
            mytable.Data{i,1}=shname;
            mytable.Data{i,2}=shdescription;
            mytable.Data{i,3}=shtime;
        end
    end
    if~isempty(shlist)
        mytable.Size=[length(shlist),3];
    else
        mytable.Size=[1,3];
        mytable.Data={'','',''};

        mytable.Name=DAStudio.message('Simulink:tools:MANoRestorepointSaved');
    end
    mytable.RowHeader={};
    mytable.HeaderVisibility=[0,1];
    mytable.ColHeader={getString(message('ModelAdvisor:engine:Name')),getString(message('ModelAdvisor:engine:Description')),getString(message('ModelAdvisor:engine:Time'))};
    mytable.ColumnCharacterWidth=[10,20,15];
    mytable.PreferredSize=[550,20*(length(shlist)+1)+50];
    mytable.CurrentItemChangedCallback=@TblCurrentItemChangedCallback;




    SaveInputPanel.Type='panel';
    SaveInputPanel.LayoutGrid=[1,4];
    SaveInputPanel.ColStretch=[0,1,0,1];
    SaveInputPanel.RowSpan=[2,2];
    SaveInputPanel.ColSpan=[1,2];
    nameTxt.Type='text';
    nameTxt.Tag='text_nameTxt';
    nameTxt.Name=[DAStudio.message('Simulink:tools:MAName'),': '];
    nameTxt.RowSpan=[1,1];
    nameTxt.ColSpan=[1,1];
    nameEdit.Type='edit';
    nameEdit.Tag='edit_nameEdit';

    nameEdit.Value=['RestorePoint',num2str(length(shlist)+1)];
    nameEdit.RowSpan=[1,1];
    nameEdit.ColSpan=[2,2];
    descriptionTxt.Type='text';
    descriptionTxt.Tag='text_descriptionTxt';
    descriptionTxt.Name=[DAStudio.message('Simulink:tools:MADescription'),': '];
    descriptionTxt.RowSpan=[1,1];
    descriptionTxt.ColSpan=[3,3];
    descriptionEdit.Type='edit';
    descriptionEdit.Tag='edit_descriptionEdit';
    descriptionEdit.RowSpan=[1,1];
    descriptionEdit.ColSpan=[4,4];
    SaveInputPanel.Items={nameTxt,nameEdit,descriptionTxt,descriptionEdit};



    ButtonPanel.Type='panel';
    ButtonPanel.LayoutGrid=[1,6];
    ButtonPanel.ColStretch=[1,1,0,0,0,0];
    loadButton.Type='pushbutton';
    loadButton.Tag='pushbutton_loadButton';
    loadButton.Name=DAStudio.message('Simulink:tools:MALoad');
    loadButton.ObjectMethod='loadBtnCB';
    loadButton.MethodArgs={'%dialog'};
    loadButton.ArgDataTypes={'handle'};
    loadButton.RowSpan=[1,1];
    loadButton.ColSpan=[3,3];
    if isempty(this.MAObj.getRestorePointList)
        loadButton.Enabled=false;
    end
    saveButton.Type='pushbutton';
    saveButton.Tag='pushbutton_saveButton';
    saveButton.Name=DAStudio.message('Simulink:tools:MASave');
    saveButton.ObjectMethod='saveBtnCB';
    saveButton.MethodArgs={'%dialog'};
    saveButton.ArgDataTypes={'handle'};
    saveButton.RowSpan=[1,1];
    saveButton.ColSpan=[3,3];
    deleteButton.Type='pushbutton';
    deleteButton.Tag='pushbutton_deleteButton';
    deleteButton.Name=DAStudio.message('Simulink:tools:MADelete');
    deleteButton.ObjectMethod='deleteBtnCB';
    deleteButton.MethodArgs={'%dialog'};
    deleteButton.ArgDataTypes={'handle'};
    deleteButton.RowSpan=[1,1];
    deleteButton.ColSpan=[4,4];
    if isempty(this.MAObj.getRestorePointList)
        deleteButton.Enabled=false;
    end
    CancelButton.Type='pushbutton';
    CancelButton.Tag='pushbutton_CancelButton';
    CancelButton.Name=DAStudio.message('Simulink:tools:MACancel');
    CancelButton.ObjectMethod='closeDialog';
    CancelButton.MethodArgs={'%dialog'};
    CancelButton.ArgDataTypes={'handle'};
    CancelButton.RowSpan=[1,1];
    CancelButton.ColSpan=[5,5];
    HelpButton.Type='pushbutton';
    HelpButton.Tag='pushbutton_HelpButton';
    HelpButton.Name=DAStudio.message('Simulink:tools:MAHelp');
    HelpButton.MatlabMethod='helpview([docroot,''/toolbox/simulink/helptargets.map''],''model_advisor_restorepoint'');';
    HelpButton.RowSpan=[1,1];
    HelpButton.ColSpan=[6,6];

    if IsSaveDlg
        if strncmp(this.MAObj.TaskAdvisorRoot.ID,'com.mathworks.FPCA.',19)
            HelpButton.MatlabMethod='helpview([docroot,''/toolbox/fixedpoint/fixedpoint.map''],''fp_save_restore_point'');';
        elseif strncmp(this.MAObj.TaskAdvisorRoot.ID,'com.mathworks.HDL.',18)
            HelpButton.MatlabMethod='helpview(''mapkey:hdlwa'',''com.mathworks.HDL.SaveRestorePoints'', ''CSHelpWindow'');';
        end
        ButtonPanel.Items={saveButton,deleteButton,CancelButton,HelpButton};
    else
        if strncmp(this.MAObj.TaskAdvisorRoot.ID,'com.mathworks.FPCA.',19)
            HelpButton.MatlabMethod='helpview([docroot,''/toolbox/fixedpoint/fixedpoint.map''],''fp_load_restore_point'');';
        elseif strncmp(this.MAObj.TaskAdvisorRoot.ID,'com.mathworks.HDL.',18)
            HelpButton.MatlabMethod='helpview(''mapkey:hdlwa'',''com.mathworks.HDL.SaveRestorePoints'', ''CSHelpWindow'');';
        end
        ButtonPanel.Items={loadButton,deleteButton,CancelButton,HelpButton};
    end




    mytable.RowSpan=[1,1];
    mytable.ColSpan=[1,2];
    if IsSaveDlg
        ButtonPanel.RowSpan=[3,3];
    else
        ButtonPanel.RowSpan=[2,2];
    end
    ButtonPanel.ColSpan=[1,2];
    dlgstruct.DialogTitle=title;
    if IsSaveDlg
        dlgstruct.Items={mytable,SaveInputPanel,ButtonPanel};
        dlgstruct.LayoutGrid=[3,2];
        dlgstruct.RowStretch=[1,0,0];
    else
        dlgstruct.Items={mytable,ButtonPanel};
        dlgstruct.LayoutGrid=[2,2];
        dlgstruct.RowStretch=[1,0];
    end
    dlgstruct.ColStretch=[0,1];

    dlgstruct.StandaloneButtonSet={''};


    function TblCurrentItemChangedCallback(dialogHandle,selectedRow,selectedCol)

        this=dialogHandle.getSource;
        shlist=this.MAObj.getRestorePointList;
        this.SelectedLineIndex=selectedRow;
        if this.IsSaveDlg&&~isempty(shlist)
            selectedSnapshot=shlist{this.SelectedLineIndex+1};
            dialogHandle.setWidgetValue('edit_nameEdit',selectedSnapshot.name);
            dialogHandle.setWidgetValue('edit_descriptionEdit',selectedSnapshot.description);
        end
