function tab=getExclusionsDialogSchema(this,tag,widgetId,mdlflag)


    data=this.getExclusionState;

    numColumns=3;


    if~mdlflag
        data=this.getDefaultExclusionState;
    end

    exclusionTable=[];


    exclusionTable.Type='table';
    exclusionTable.ColHeader={DAStudio.message('sl_pir_cpp:creator:blockFullPath'),...
    DAStudio.message('ModelAdvisor:engine:ExclusionType'),...
    DAStudio.message('ModelAdvisor:engine:ExclusionRationale'),...
    };

    exclusionTable.Size=[size(data,1),numColumns];
    exclusionTable.Data=data;
    exclusionTable.SelectionBehavior='Row';
    exclusionTable.HeaderVisibility=[0,1];
    exclusionTable.Editable=true;
    exclusionTable.RowSpan=[3,3];
    exclusionTable.ColSpan=[1,numColumns];
    exclusionTable.ReadOnlyColumns=0:1;
    exclusionTable.ColumnStretchable=[1,1,1];
    exclusionTable.ValueChangedCallback=@tableChanged;
    exclusionTable.Mode=true;
    exclusionTable.DialogRefresh=true;
    exclusionTable.Tag=[tag,'Table'];
    exclusionTable.WidgetId=[widgetId,'Table'];

    modelName.Type='text';
    modelName.Name=[DAStudio.message('ModelAdvisor:engine:ExclusionModel'),' ',this.fModelName];
    modelName.RowSpan=[1,1];
    modelName.ColSpan=[1,3];
    modelName.Tag=[tag,'ModelName'];

    excludeModelRef.Type='checkbox';
    excludeModelRef.Value=this.excludeModelReferences;
    excludeModelRef.Name=DAStudio.message('sl_pir_cpp:creator:excludeModelRefs');
    excludeModelRef.RowSpan=[1,1];
    excludeModelRef.ColSpan=[1,1];
    excludeModelRef.ObjectMethod='excludeModelReferencescb';
    excludeModelRef.Tag='excludeModelReferences';

    excludeLibraryLinks.Type='checkbox';
    excludeLibraryLinks.Value=this.excludeLibraryLinks;
    excludeLibraryLinks.Name=DAStudio.message('sl_pir_cpp:creator:excludeLibLinks');
    excludeLibraryLinks.RowSpan=[1,1];
    excludeLibraryLinks.ColSpan=[2,2];
    excludeLibraryLinks.ObjectMethod='excludeLibraryLinkscb';
    excludeLibraryLinks.Tag='excludeLibraryLinks';

    excludeInactiveRegions.Type='checkbox';
    excludeInactiveRegions.Value=this.excludeInactiveRegions;
    excludeInactiveRegions.Name=['^',DAStudio.message('sl_pir_cpp:creator:excludeInactiveRegions')];
    excludeInactiveRegions.RowSpan=[2,2];
    excludeInactiveRegions.ColSpan=[1,2];
    excludeInactiveRegions.ObjectMethod='excludeInactiveRegionscb';
    excludeInactiveRegions.Tag='excludeInactiveRegions';

    Description.Type='text';
    Description.Name=DAStudio.message('sl_pir_cpp:creator:CheckRequiresCompile');
    Description.RowSpan=[3,3];
    Description.ColSpan=[1,2];

    excludeOptions.Type='group';
    excludeOptions.Name=DAStudio.message('sl_pir_cpp:creator:excludeOptionsTitle');
    excludeOptions.LayoutGrid=[3,2];
    excludeOptions.Flat=true;
    excludeOptions.Items={excludeModelRef,excludeLibraryLinks,excludeInactiveRegions,Description};
    excludeOptions.RowSpan=[2,2];
    excludeOptions.ColSpan=[1,3];

    removeButton.Name=DAStudio.message('ModelAdvisor:engine:ExclusionRemove');
    removeButton.Type='pushbutton';
    removeButton.RowSpan=[4,4];
    removeButton.ColSpan=[1,1];

    if~enableRemoveExclusion(this.exclusionState)
        removeButton.Enabled=false;
    end

    removeButton.ObjectMethod='removeExclusionCallback';
    removeButton.MatlabMethod='removeExclusionCallback';
    removeButton.MethodArgs={'%dialog'};
    removeButton.ArgDataTypes={'handle'};
    removeButton.DialogRefresh=true;
    removeButton.Tag=[tag,'exclusionRemoveItem'];
    removeButton.WidgetId=[widgetId,'exclusionRemoveItem'];


    excludesystemDscp.Type='text';
    excludesystemDscp.Name=DAStudio.message('sl_pir_cpp:creator:ExcludeSubsystemDescription');
    excludesystemDscp.RowSpan=[1,1];
    excludesystemDscp.ColSpan=[1,3];


    excludeTableGroup.Type='group';
    excludeTableGroup.Name=DAStudio.message('sl_pir_cpp:creator:excludeTableGroupTitle');
    excludeTableGroup.LayoutGrid=[2,2];
    excludeTableGroup.Flat=true;
    excludeTableGroup.Items={excludesystemDscp,exclusionTable,removeButton};
    excludeTableGroup.RowSpan=[3,3];
    excludeTableGroup.ColSpan=[1,3];

    editButton.Name=DAStudio.message('ModelAdvisor:engine:ExclusionEdit');
    editButton.Type='pushbutton';
    editButton.RowSpan=[3,3];
    editButton.ColSpan=[numColumns,numColumns];
    editButton.ObjectMethod='editExclusionCallback';
    editButton.MethodArgs={'%dialog'};
    editButton.ArgDataTypes={'handle'};
    editButton.DialogRefresh=true;
    editButton.Tag=[tag,'exclusionEditItem'];
    editButton.WidgetId=[widgetId,'exclusionEditItem'];

    groupExclusionState.Type='group';
    groupExclusionState.Name=DAStudio.message('ModelAdvisor:engine:ExclusionGroup');
    groupExclusionState.LayoutGrid=[1,1];
    groupExclusionState.Flat=true;
    if~strcmp(tag,'ModelExclusions')
        groupExclusionState.Items={excludeTableGroup};
    else
        groupExclusionState.Items={modelName,excludeOptions,excludeTableGroup};
    end

    if~mdlflag
        groupExclusionState.Items=[groupExclusionState.Items,editButton];
    end

    exclusionFileName.Name=DAStudio.message('ModelAdvisor:engine:ExclusionFileName');
    exclusionFileName.Type='edit';
    exclusionFileName.Enabled=false;
    exclusionFileName.RowSpan=[1,1];
    exclusionFileName.ColSpan=[1,2];
    if~mdlflag
        exclusionFileName.ObjectProperty='defaultExclusionFile';
        exclusionFileName.Tag=[tag,'defaultExclusionFilename'];
    else
        exclusionFileName.Tag=[tag,'ModelExclusionFilename'];
        exclusionFileName.Value=this.getFileNameToDisplay;
    end
    exclusionFileName.WidgetId=[widgetId,'ExclusionFilename'];


    changeExclusionFile.Name=DAStudio.message('ModelAdvisor:engine:ChangeExclusionFileName');
    changeExclusionFile.Type='pushbutton';
    changeExclusionFile.RowSpan=[1,1];
    changeExclusionFile.ColSpan=[3,3];
    changeExclusionFile.ObjectMethod='changeExclusionFile';
    changeExclusionFile.Tag=[tag,'ExclusionFileChange'];
    changeExclusionFile.WidgetId=[widgetId,'ExclusionFileChange'];

    saveExclusion.Type='group';
    saveExclusion.Name=DAStudio.message('ModelAdvisor:engine:ExclusionFile');
    saveExclusion.LayoutGrid=[2,2];
    saveExclusion.Flat=true;
    if this.setExclusionFileFlag
        groupExclusionState.Visible=false;
        tab.Items={saveExclusion,groupExclusionState};
    end

    storeInSLX.Type='checkbox';
    if~this.isSLX
        storeInSLX.Visible=false;
    end
    storeInSLX.Value=this.storeInSLX;
    storeInSLX.Name=DAStudio.message('ModelAdvisor:engine:ExclusionStoreInSlx');
    storeInSLX.RowSpan=[2,2];
    storeInSLX.ColSpan=[1,3];
    storeInSLX.ObjectMethod='storeInSLXcb';
    storeInSLX.Tag='storeInSLX';
    storeInSLX.DialogRefresh=true;
    if this.storeInSLX
        exclusionFileName.Visible=false;
        changeExclusionFile.Visible=false;
    else
        exclusionFileName.Visible=true;
        changeExclusionFile.Visible=true;
    end
    saveExclusion.Items={exclusionFileName,changeExclusionFile,storeInSLX};

    tab.LayoutGrid=[3,1];
    tab.Items={saveExclusion,groupExclusionState};

    if this.setExclusionFileFlag
        groupExclusionState.Visible=false;
        tab.Items={saveExclusion};
    end

    function flag=enableRemoveExclusion(exclusionState)
        allkeys=exclusionState.keys;
        flag=false;

        if(isempty(allkeys))
            return;
        end
        for i=1:length(allkeys)
            prop=exclusionState(allkeys{i});
            if~strcmp(prop.value,'InactiveRegions')&&~strcmp(prop.value,'LibraryLinks')&&~strcmp(prop.value,'ModelReference')
                flag=true;
                return;
            end
        end


        function tableChanged(dlg,ridx,cidx,value)


            ridx=ridx+1;
            cidx=cidx+1;

            if cidx==4
                dp=DAStudio.DialogProvider;
                dp.errordlg(DAStudio.message('ModelAdvisor:engine:CannotEditCheckIDColumn'),'Error',true);
                dlg.restoreFromSchema;
                return;
            end

            editor=dlg.getSource;
            if editor.activeTabIndex==0
                tableIdxMap=editor.tableIdxMap;
            else
                tableIdxMap=editor.defaultTableIdxMap;
            end
            if tableIdxMap.isKey(ridx)
                prop=tableIdxMap(ridx);
                if editor.activeTabIndex==0
                    editor.removeExclusionByProp(prop,true);
                else
                    editor.removeExclusionByProp(prop,false);
                end

                switch cidx
                case 1
                    prop.rationale=value;
                case 3
                    prop.Value=value;
                case 4
                    prop.checkIDs=value;
                end

                if editor.activeTabIndex==0
                    editor.addExclusionPropToState(prop);
                else
                    editor.addExclusionPropToDefaultState(prop);
                end
            end

            if~isempty(editor.fDialogHandle)
                editor.fDialogHandle.refresh();
                editor.fDialogHandle.enableApplyButton(true);
            end
