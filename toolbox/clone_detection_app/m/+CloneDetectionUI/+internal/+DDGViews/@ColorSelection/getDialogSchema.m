function dlgStruct=getDialogSchema(this)

    exactColorLabel.Type='text';
    exactColorLabel.Tag='exactColorLabelTag';
    exactColorLabel.Name=DAStudio.message('sl_pir_cpp:creator:exactColorLabel');
    exactColorLabel.RowSpan=[1,1];
    exactColorLabel.ColSpan=[1,1];

    exactColorCombo.Name=DAStudio.message('sl_pir_cpp:creator:exactColorLabel');
    exactColorCombo.Type='combobox';
    exactColorCombo.RowSpan=[1,1];
    exactColorCombo.ColSpan=[2,2];
    exactColorCombo.Value=this.cloneUIObj.colorCodes.exactColor;
    exactColorCombo.Mode=1;
    exactColorCombo.Entries={'red','lightBlue','green','orange','none'};
    exactColorCombo.ObjectMethod='dirtyEditor';
    exactColorCombo.Tag='exactColorComboTag';

    similarColorLabel.Type='text';
    similarColorLabel.Tag='similarColorLabelTag';
    similarColorLabel.Name=DAStudio.message('sl_pir_cpp:creator:similarClonesColorLabel');
    similarColorLabel.RowSpan=[2,2];
    similarColorLabel.ColSpan=[1,1];

    similarColorCombo.Name=DAStudio.message('sl_pir_cpp:creator:similarClonesColorLabel');
    similarColorCombo.Type='combobox';
    similarColorCombo.RowSpan=[2,2];
    similarColorCombo.ColSpan=[2,2];
    similarColorCombo.Value=this.cloneUIObj.colorCodes.similarColor;
    similarColorCombo.Mode=1;
    similarColorCombo.Entries={'red','lightBlue','green','orange','none'};
    similarColorCombo.ObjectMethod='dirtyEditor';
    similarColorCombo.Tag='similarColorComboTag';

    excludedColorLabel.Type='text';
    excludedColorLabel.Tag='eexcludedColorLabelTag';
    excludedColorLabel.Name=DAStudio.message('sl_pir_cpp:creator:excludedColorLabel');
    excludedColorLabel.RowSpan=[3,3];
    excludedColorLabel.ColSpan=[1,1];

    excludedColorCombo.Name=DAStudio.message('sl_pir_cpp:creator:excludedColorLabel');
    excludedColorCombo.Type='combobox';
    excludedColorCombo.RowSpan=[3,3];
    excludedColorCombo.ColSpan=[2,2];
    excludedColorCombo.Entries={'gray','none'};
    excludedColorCombo.Value=this.cloneUIObj.colorCodes.exclusionColor;
    excludedColorCombo.Mode=1;
    excludedColorCombo.ObjectMethod='dirtyEditor';
    excludedColorCombo.Tag='excludedColorComboTag';

    groupColorSettings.Type='group';
    groupColorSettings.Name='colorComboGroup';
    groupColorSettings.LayoutGrid=[3,2];
    groupColorSettings.Flat=true;
    groupColorSettings.Items={exactColorCombo,similarColorCombo,excludedColorCombo,...
    excludedColorLabel,similarColorLabel,exactColorLabel};

    dlgStruct.DialogTitle=this.title;
    dlgStruct.DialogTag='ColorSelection';
    dlgStruct.Items={groupColorSettings};
    dlgStruct.PostApplyMethod='postApply';
    dlgStruct.DisplayIcon=fullfile('toolbox','clone_detection_app','m','ui',...
    'images','detect_16.png');
    dlgStruct.LayoutGrid=[4,3];
end
