function dlgstruct=enumtypeddg(dlgSource,obj,objName)


    isValidSource=false;
    if~isempty(dlgSource)
        try
            isValidSource=dlgSource.isValidSourceForEnum();
        catch
        end
    end
    if isValidSource
        dlgData=dlgSource.getUserData();

        numEnums=obj.numEnumerals;

        try
            bIsUpToDate=dlgData.isUpToDate;
        catch
            bIsUpToDate=false;
        end
        if~bIsUpToDate

            dlgData.SelectedRow=0;




            dlgData.enumeration=cell(numEnums,3);
            for e=1:numEnums
                [n,v,d]=obj.enumeralAt(e);
                dlgData.enumeration{e,1}=n;
                dlgData.enumeration{e,2}=v;
                dlgData.enumeration{e,3}=d;
            end

            dlgData.isUpToDate=true;
        end



        tableData=cell(numEnums,3);
        defaultFieldEntries=cell(numEnums,1);
        for e=1:numEnums
            [n,v,d]=obj.enumeralAt(e);
            tableData{e,1}=loc_cellWidget(n);
            tableData{e,2}=loc_cellWidget(v);
            tableData{e,3}=loc_cellWidget(d);

            defaultFieldEntries(e,1)={n};
        end


        pAdd.Name='';
        pAdd.Type='pushbutton';
        pAdd.RowSpan=[1,1];
        pAdd.ColSpan=[1,1];
        pAdd.Enabled=1;
        pAdd.FilePath=fullfile(matlabroot,'toolbox/shared/dastudio/resources/add_row.gif');
        pAdd.ToolTip=DAStudio.message('Simulink:dialog:EnumTypeAddTip');
        pAdd.Tag='AddButton';
        pAdd.MatlabMethod='Simulink.dd.enumtypeddg_cb';
        pAdd.MatlabArgs={'doAdd','%dialog'};


        pDelete.Name='';
        pDelete.Type='pushbutton';
        pDelete.RowSpan=[2,2];
        pDelete.ColSpan=[1,1];
        pDelete.Enabled=(numEnums>1);
        pDelete.FilePath=fullfile(matlabroot,'toolbox/shared/dastudio/resources/delete.gif');
        pDelete.ToolTip=DAStudio.message('Simulink:dialog:EnumTypeDeleteTip');
        pDelete.Tag='DeleteButton';
        pDelete.MatlabMethod='Simulink.dd.enumtypeddg_cb';
        pDelete.MatlabArgs={'doDelete','%dialog'};


        pUp.Name='';
        pUp.Type='pushbutton';
        pUp.RowSpan=[3,3];
        pUp.ColSpan=[1,1];
        pUp.FilePath=fullfile(matlabroot,'toolbox/shared/dastudio/resources/move_up.gif');
        pUp.ToolTip=DAStudio.message('Simulink:dialog:EnumTypeUpTip');
        pUp.Tag='UpButton';
        pUp.Enabled=((dlgData.SelectedRow+1)>1);
        pUp.MatlabMethod='Simulink.dd.enumtypeddg_cb';
        pUp.MatlabArgs={'doUp','%dialog'};


        pDown.Name='';
        pDown.Type='pushbutton';
        pDown.RowSpan=[4,4];
        pDown.ColSpan=[1,1];
        pDown.FilePath=fullfile(matlabroot,'toolbox/shared/dastudio/resources/move_down.gif');
        pDown.ToolTip=DAStudio.message('Simulink:dialog:EnumTypeDownTip');
        pDown.Tag='DownButton';
        pDown.Enabled=((dlgData.SelectedRow+1)<numEnums);
        pDown.MatlabMethod='Simulink.dd.enumtypeddg_cb';
        pDown.MatlabArgs={'doDown','%dialog'};

        spacer1.Name='';
        spacer1.Type='text';
        spacer1.RowSpan=[5,5];
        spacer1.ColSpan=[1,1];

        panel1.Type='panel';
        panel1.Items={pAdd,pDelete,pUp,pDown,spacer1};
        panel1.LayoutGrid=[5,1];
        panel1.RowStretch=[0,0,0,0,1];
        panel1.RowSpan=[1,1];
        panel1.ColSpan=[1,1];

        pTable.Name='';
        pTable.Type='table';
        pTable.Size=[numEnums,3];
        pTable.Data=tableData;
        pTable.Grid=1;
        pTable.ColHeader={DAStudio.message('Simulink:dialog:EnumTypeTableNameColumn'),...
        DAStudio.message('Simulink:dialog:EnumTypeTableValueColumn'),...
        DAStudio.message('Simulink:dialog:EnumTypeTableDescriptionColumn')};
        pTable.HeaderVisibility=[0,1];
        pTable.ColumnCharacterWidth=[10,5,20];
        pTable.RowSpan=[1,1];
        pTable.ColSpan=[2,2];
        pTable.Enabled=1;
        pTable.Editable=1;
        pTable.LastColumnStretchable=1;
        pTable.MinimumSize=[250,50];
        pTable.Tag='Enumerals';
        pTable.CurrentItemChangedCallback=@loc_TableSelectionChanged;
        pTable.ValueChangedCallback=@loc_TableValueChanged;
        pTable.SelectedRow=dlgData.SelectedRow;
        pTable.SelectionBehavior='Row';

        enumeralsGrp.Name=DAStudio.message('Simulink:dialog:EnumTypeEnumeration');
        enumeralsGrp.Type='group';
        enumeralsGrp.LayoutGrid=[1,2];
        enumeralsGrp.ColStretch=[0,1];
        enumeralsGrp.ColSpan=[1,2];
        enumeralsGrp.RowSpan=[1,1];
        enumeralsGrp.Items={panel1,pTable};

        defaultValueLabel.Name=DAStudio.message('Simulink:dialog:EnumTypeDefault');
        defaultValueLabel.Type='text';
        defaultValueLabel.RowSpan=[1,1];
        defaultValueLabel.ColSpan=[1,1];

        defaultValueField.Type='combobox';
        defaultValueField.Entries=defaultFieldEntries;
        defaultValueField.ObjectProperty='DefaultValue';
        defaultValueField.Tag='DefaultValue';
        defaultValueField.RowSpan=[1,1];
        defaultValueField.ColSpan=[2,2];

        storageTypeLabel.Name=DAStudio.message('Simulink:dialog:EnumTypeStorageType');
        storageTypeLabel.Type='text';
        storageTypeLabel.RowSpan=[2,2];
        storageTypeLabel.ColSpan=[1,1];

        storageTypeField.Type='combobox';
        storageTypeField.Entries=obj.getPropAllowedValues('StorageType');
        storageTypeField.ObjectProperty='StorageType';
        storageTypeField.Tag='StorageType';
        storageTypeField.RowSpan=[2,2];
        storageTypeField.ColSpan=[2,2];





        dataScopeLabel.Name=DAStudio.message('Simulink:dialog:EnumTypeDataScope');
        dataScopeLabel.Type='text';
        dataScopeLabel.RowSpan=[1,1];
        dataScopeLabel.ColSpan=[1,1];

        dataScopeField.Type='combobox';
        dataScopeField.Entries=obj.getPropAllowedValues('DataScope');
        dataScopeField.ObjectProperty='DataScope';
        dataScopeField.Tag='DataScope';
        dataScopeField.RowSpan=[1,1];
        dataScopeField.ColSpan=[2,2];

        headerFileLabel.Name=DAStudio.message('Simulink:dialog:EnumTypeHeaderFile');
        headerFileLabel.Type='text';
        headerFileLabel.RowSpan=[2,2];
        headerFileLabel.ColSpan=[1,1];

        headerFileField.Type='edit';
        headerFileField.ObjectProperty='HeaderFile';
        headerFileField.Tag='HeaderFile';
        headerFileField.RowSpan=[2,2];
        headerFileField.ColSpan=[2,2];

        addClassNameCheckbox.Name=DAStudio.message('Simulink:dialog:EnumTypeAddClassName');
        addClassNameCheckbox.Type='checkbox';
        addClassNameCheckbox.Tag='AddClassNameCheckbox';
        addClassNameCheckbox.ObjectProperty='AddClassNameToEnumNames';
        addClassNameCheckbox.ToolTip=DAStudio.message('SLDD:sldd:EnumAddClassNameTooltip');
        addClassNameCheckbox.RowSpan=[3,3];
        addClassNameCheckbox.ColSpan=[1,2];





        grpCodeGen.Items={};
        grpCodeGen.Items={dataScopeLabel,dataScopeField,headerFileLabel,...
        headerFileField,addClassNameCheckbox};
        grpCodeGen.LayoutGrid=[4,2];
        grpCodeGen.Name=DAStudio.message('Simulink:dialog:DataCodeGenOptionsPrompt');
        grpCodeGen.Type='group';
        grpCodeGen.RowSpan=[1,1];
        grpCodeGen.ColSpan=[1,2];
        grpCodeGen.RowStretch=[0,0,0,1];
        grpCodeGen.ColStretch=[0,1];
        grpCodeGen.Tag='grpCodeGen_tag';
        tabCodeGen=createCodeGenTab(grpCodeGen);
        if isfield(dlgData,'Visible')
            tabCodeGen.Visible=dlgData.Visible;
        end

        attrsPanel.Type='panel';
        attrsPanel.Items={defaultValueLabel,defaultValueField};

        attrsPanel.Items={attrsPanel.Items{:},storageTypeLabel,storageTypeField};


        attrsPanel.LayoutGrid=[3,2];
        attrsPanel.RowSpan=[2,2];
        attrsPanel.ColSpan=[1,1];

        description.Name=DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
        description.Type='editarea';
        description.Tag='Description';
        description.RowSpan=[3,3];
        description.ColSpan=[1,2];
        description.ObjectProperty='Description';





        tabDesign.Name=DAStudio.message('Simulink:dialog:DataTab1Prompt');
        tabDesign.LayoutGrid=[4,2];
        tabDesign.RowStretch=[0,0,0,1];
        tabDesign.ColStretch=[0,1];
        tabDesign.Source=obj;
        tabDesign.Items={enumeralsGrp,attrsPanel,description};
        tabDesign.Tag='TabDesign';

        dlgstruct.PostRevertCallback='Simulink.dd.enumtypeddg_cb';
        dlgstruct.PostRevertArgs={'doRevert','%dialog'};

        dlgstruct.DialogTitle=[DAStudio.message('Simulink:dialog:EnumTypeTitle'),objName];

        tabWhole.Type='tab';
        tabWhole.Tag='TabWhole';
        tabWhole.Tabs={tabDesign,tabCodeGen};
        dlgstruct.Items={tabWhole};

        dlgSource.setUserData(dlgData);
    else

        image.Type='image';
        image.Tag='image';
        image.RowSpan=[1,1];
        image.ColSpan=[1,1];
        image.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','error.png');
        messageText.Name=DAStudio.message(...
        'Simulink:dialog:EnumTypeDialogOutsideDictionary',objName);
        messageText.Type='text';
        messageText.WordWrap=true;
        messageText.RowSpan=[1,1];
        messageText.ColSpan=[2,2];

        widgets.Type='panel';
        widgets.Tag='widgetsPanel';
        widgets.Items={image,messageText};
        widgets.Alignment=6;
        widgets.LayoutGrid=[1,2];

        dlgstruct.DialogTitle=objName;
        dlgstruct.Items={widgets};
    end

    dlgstruct.OpenCallback=@onDialogOpen;

    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'data_dictionary'};
end


function onDialogOpen(dlg)
    dlgSrc=dlg.getDialogSource();
    if any(strcmp(methods(class(dlgSrc)),'useCodeGen'))
        dlgData=dlgSrc.getUserData;
        dlgData.Visible=dlgSrc.useCodeGen();
        dlgSrc.setUserData(dlgData);
        dlg.setVisible('TabCodeGen',dlgData.Visible);
    end
end


function loc_TableSelectionChanged(dialogH,row,~)
    source=dialogH.getSource;

    enabled=(row>=0);

    if~enabled
        return;
    end


    dialogH.selectTableRow('Enumerals',row);


    enumTypeSpec=source.getForwardedObject;
    assert(isa(enumTypeSpec,'Simulink.data.dictionary.EnumTypeDefinition'));
    numEnums=enumTypeSpec.numEnumerals;
    dialogH.setEnabled('UpButton',((row+1)>1));
    dialogH.setEnabled('DownButton',((row+1)<numEnums));


    dlgData=source.getUserData();
    dlgData.SelectedRow=row;


    source.setUserData(dlgData);
end


function loc_TableValueChanged(dialogH,row,col,newVal)

    source=dialogH.getSource;
    enumTypeSpec=source.getForwardedObject;
    assert(isa(enumTypeSpec,'Simulink.data.dictionary.EnumTypeDefinition'));
    enumNum=row+1;


    switch col
    case 0
        newName=strtrim(newVal);
        if(~isempty(newName))&&...
            isvarname(newName)&&...
            ~enumTypeSpec.hasEnumeral(newName)
            enumTypeSpec.setEnumName(enumNum,newName);
        else

            [origName,~,~]=enumTypeSpec.enumeralAt(enumNum);
            dialogH.setTableItemValue('Enumerals',row,col,origName);
        end
    case 1
        v=str2double(newVal);
        if(~isnan(v))&&isreal(v)&&isscalar(v)
            enumTypeSpec.setEnumValue(enumNum,num2str(floor(v)));
        else

            [~,origVal,~]=enumTypeSpec.enumeralAt(enumNum);
            dialogH.setTableItemValue('Enumerals',row,col,origVal);
        end
    case 2
        enumTypeSpec.setEnumDescription(enumNum,newVal);
    end
    dialogH.refresh;
end



function widget=loc_cellWidget(cellText)
    widget.Type='edit';
    widget.Value=cellText;
end
