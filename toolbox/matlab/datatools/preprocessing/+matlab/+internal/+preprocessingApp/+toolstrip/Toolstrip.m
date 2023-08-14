classdef Toolstrip<handle




    properties(Constant)

        DEFAULT_PPMODE_GALLERY_WIDTH(1,1)double=150
        DEFAULT_PPMODE_GALLERY_MAX_COLS(1,1)double=5
        DEFAULT_PPMODE_GALLERY_MIN_COLS(1,1)double=1


        IMPORT_WORKSPACE_TAG="import_workspace";
        IMPORT_FILE_TAG="import_file";
        EXPORT_WORKSPACE_TAG="export_workspace";
        EXPORT_SCRIPT_TAG="export_script";
        EXPORT_FUNCTION_TAG="export_function";
    end

    properties

        HOME_TOOLSTRIP_TAG;
        MODE_TOOLSTRIP_TAG;


        HomeTabGroup;
        HomeTab;
        ImportButton;
        ExportButton;
        FeedbackButton;
        SummaryButton;
        LegendButton;
        AxToolBarButton;

        ColumnTransformationButton;
        PreprocessingGallery;
        PreprocessingGalleryPopup;
        PreprocessingGalleryItems;
        PreprocessingGalleryCategories;
        AddCustomFunctionButton;
        EditCustomFunctionButton;


        PreprocessingTabGroup;
        PreprocessingTab;
        ApplyButton;
        CancelButton;
        subsetDataCB;
        subsetStartSpinner;
        subsetEndSpinner;
        subsetStepSpinner;


        QuickAccessBar;
    end

    properties(SetAccess=protected)
        State_I;
    end

    properties(Dependent)
        State;
    end

    methods
        function set.State(this,state)
            this.PreprocessingGallery.Enabled=state;
            galleryItems=this.PreprocessingGalleryItems.values;
            for i=1:length(galleryItems)
                galleryItems{i}.Enabled=state;
            end
            this.ExportButton.Enabled=state;
            this.SummaryButton.Enabled=state;
            this.LegendButton.Enabled=state;
            this.AxToolBarButton.Enabled=state;
            this.State_I=state;
        end

        function val=get.State(this)
            val=this.State_I;
        end

        function this=Toolstrip(homeToolstripTag,modeToolstripTag,galleryTasks)
            this.HOME_TOOLSTRIP_TAG=homeToolstripTag;
            this.MODE_TOOLSTRIP_TAG=modeToolstripTag;

            this.buildHomeToolstripTab(galleryTasks);
            this.buildPPModeToolstripTab();


            this.QuickAccessBar=matlab.ui.internal.toolstrip.qab.QABHelpButton();
        end

        function buildHomeToolstripTab(this,galleryTasks)

            import matlab.ui.internal.toolstrip.*

            this.HomeTabGroup=TabGroup();
            this.HomeTabGroup.Tag=this.HOME_TOOLSTRIP_TAG;
            this.HomeTabGroup.Contextual=false;
            this.HomeTab=Tab(getString(message('MATLAB:datatools:preprocessing:app:HOME_TAB')));
            this.HomeTab.Tag="homeTab";
            this.HomeTabGroup.add(this.HomeTab);

            this.buildImportSection(this.HomeTab);
            this.createPreprocessingModeGallery(this.HomeTab,galleryTasks);
            this.buildFeedbackSection(this.HomeTab);
            this.buildExportSection(this.HomeTab);
        end

        function buildImportSection(this,tab)
            import matlab.ui.internal.toolstrip.*

            section=tab.addSection(getString(message('MATLAB:datatools:preprocessing:app:FILE_SECTION')));
            section.Tag="fileSection";
            column=section.addColumn();

            this.ImportButton=DropDownButton(getString(message('MATLAB:datatools:preprocessing:app:IMPORT_BUTTON_TEXT')),Icon.IMPORT_24);
            this.ImportButton.Tag="importData";


            importWorkspace=matlab.ui.internal.toolstrip.ListItem(getString(message('MATLAB:datatools:preprocessing:app:IMPORT_WORKSPACE')),Icon.IMPORT_16);
            importWorkspace.Tag=this.IMPORT_WORKSPACE_TAG;
            importFile=matlab.ui.internal.toolstrip.ListItem(getString(message('MATLAB:datatools:preprocessing:app:IMPORT_FILE')),Icon.BROWSE_16);
            importFile.Tag=this.IMPORT_FILE_TAG;

            popup=matlab.ui.internal.toolstrip.PopupList;
            popup.add(importWorkspace);
            popup.add(importFile);
            this.ImportButton.Popup=popup;
            this.ImportButton.Description=getString(message('MATLAB:datatools:preprocessing:app:IMPORT_BUTTON_DESCRIPTION'));
            column.add(this.ImportButton);
        end

        function buildExportSection(this,tab)
            import matlab.ui.internal.toolstrip.*

            section=tab.addSection(getString(message('MATLAB:datatools:preprocessing:app:EXPORT_SECTION')));
            section.Tag="exportSection";
            column=section.addColumn();

            exportWorkspace=matlab.ui.internal.toolstrip.ListItem(getString(message('MATLAB:datatools:preprocessing:app:EXPORT_WORKSPACE')),Icon.EXPORT_16);
            exportWorkspace.Tag=this.EXPORT_WORKSPACE_TAG;
            exportScript=matlab.ui.internal.toolstrip.ListItem(getString(message('MATLAB:datatools:preprocessing:app:EXPORT_SCRIPT')),Icon.SAVE_AS_16);
            exportScript.Tag=this.EXPORT_SCRIPT_TAG;
            exportFunction=matlab.ui.internal.toolstrip.ListItem(getString(message('MATLAB:datatools:preprocessing:app:EXPORT_FUNCTION')),Icon.SAVE_AS_16);
            exportFunction.Tag=this.EXPORT_FUNCTION_TAG;

            this.ExportButton=SplitButton(getString(message('MATLAB:datatools:preprocessing:app:EXPORT_BUTTON_TEXT')),Icon.EXPORT_24);
            popup=matlab.ui.internal.toolstrip.PopupList;
            popup.add(exportWorkspace);
            popup.add(exportScript);
            popup.add(exportFunction);
            this.ExportButton.Popup=popup;

            this.ExportButton.Tag="exportData";
            this.ExportButton.Description=getString(message('MATLAB:datatools:preprocessing:app:EXPORT_BUTTON_DESCRIPTION'));
            column.add(this.ExportButton);
        end

        function buildFeedbackSection(this,tab)
            import matlab.ui.internal.toolstrip.*

            section=tab.addSection(getString(message('MATLAB:datatools:preprocessing:app:VIEW_SECTION')));
            section.Tag="ViewSection";

            column=section.addColumn();
            this.LegendButton=CheckBox(getString(message('MATLAB:datatools:preprocessing:app:LEGEND')));
            this.LegendButton.Description=getString(message('MATLAB:datatools:preprocessing:app:LEGEND'));
            this.LegendButton.Tag="Legend";
            this.LegendButton.Value=true;
            column.add(this.LegendButton);

            this.SummaryButton=CheckBox(getString(message('MATLAB:datatools:preprocessing:app:SHOW_SUMMARY')));
            this.SummaryButton.Description=getString(message('MATLAB:datatools:preprocessing:app:SHOW_SUMMARY'));
            this.SummaryButton.Tag="Summary";
            this.SummaryButton.Value=true;
            column.add(this.SummaryButton);
        end

        function buildPPModeToolstripTab(this)
            import matlab.ui.internal.toolstrip.*

            this.PreprocessingTabGroup=TabGroup();
            this.PreprocessingTabGroup.Tag=this.MODE_TOOLSTRIP_TAG;
            this.PreprocessingTabGroup.Contextual=true;

            this.PreprocessingTab=Tab(getString(message('MATLAB:datatools:preprocessing:app:PPTAB')));
            this.PreprocessingTab.Tag="preprocessingTab";

            this.PreprocessingTabGroup.add(this.PreprocessingTab);

            this.buildSubsetSection();

            ppSection=this.PreprocessingTab.addSection(getString(message('MATLAB:datatools:preprocessing:app:PPMODE_SECTION')));
            ppSection.Tag="PreProcessingSection";
            column=ppSection.addColumn();

            this.ApplyButton=Button(getString(message('MATLAB:datatools:preprocessing:app:PPMODE_APPLY_BUTTON_TEXT')),Icon.CONFIRM_24);
            this.ApplyButton.Tag="ApplyPpMode";
            this.ApplyButton.Description=getString(message('MATLAB:datatools:preprocessing:app:PPMODE_APPLY_BUTTON_DESCRIPTION'));
            column.add(this.ApplyButton);

            column=ppSection.addColumn();
            this.CancelButton=Button(getString(message('MATLAB:datatools:preprocessing:app:PPMODE_CANCEL_BUTTON_TEXT')),Icon.CLOSE_24);
            this.CancelButton.Tag="CancelPpMode";
            this.CancelButton.Description=getString(message('MATLAB:datatools:preprocessing:app:PPMODE_CANCEL_BUTTON_DESCRIPTION'));
            column.add(this.CancelButton);
        end

        function buildSubsetSection(this)
            import matlab.ui.internal.toolstrip.*

            subsetSection=this.PreprocessingTab.addSection(getString(message('MATLAB:datatools:preprocessing:app:PPMODE_SUBSET_SECTION')));
            subsetSection.Tag="PreProcessingSubsetSection";
            subsetColumn=subsetSection.addColumn();

            this.subsetDataCB=CheckBox(getString(message('MATLAB:datatools:preprocessing:app:PPMODE_SUBSET_CHECKBOX_TEXT')));
            this.subsetDataCB.Description=getString(message('MATLAB:datatools:preprocessing:app:PPMODE_SUBSET_CHECKBOX_DESCRIPTION'));
            this.subsetDataCB.Tag="PreProcessingSubsetDataCB";
            this.subsetDataCB.Value=true;
            subsetColumn.add(this.subsetDataCB);

            subsetLabelsColumn=subsetSection.addColumn('Width',50);
            subsetStartLabel=Label(getString(message('MATLAB:datatools:preprocessing:app:PPMODE_SUBSET_START_TEXT')));
            subsetStartLabel.Description=getString(message('MATLAB:datatools:preprocessing:app:PPMODE_SUBSET_START_DESCRIPTION'));
            subsetStartLabel.Tag="PreProcessingSubsetStartLabel";
            subsetEndLabel=Label(getString(message('MATLAB:datatools:preprocessing:app:PPMODE_SUBSET_END_TEXT')));
            subsetEndLabel.Description=getString(message('MATLAB:datatools:preprocessing:app:PPMODE_SUBSET_END_DESCRIPTION'));
            subsetEndLabel.Tag="PreProcessingSubsetEndLabel";
            subsetStepLabel=Label(getString(message('MATLAB:datatools:preprocessing:app:PPMODE_SUBSET_STEP_TEXT')));
            subsetStepLabel.Description=getString(message('MATLAB:datatools:preprocessing:app:PPMODE_SUBSET_STEP_DESCRIPTION'));
            subsetStepLabel.Tag="PreProcessingSubsetStepLabel";
            subsetLabelsColumn.add(subsetStartLabel);
            subsetLabelsColumn.add(subsetEndLabel);
            subsetLabelsColumn.add(subsetStepLabel);

            subsetValuesColumn=subsetSection.addColumn();
            this.subsetStartSpinner=Spinner([1,1000000000],1);
            this.subsetStartSpinner.Tag="PreProcessingSubsetStartSpinner";
            this.subsetStartSpinner.Description=getString(message('MATLAB:datatools:preprocessing:app:PPMODE_SUBSET_START_DESCRIPTION'));
            this.subsetEndSpinner=Spinner([1,1000000000],10000);
            this.subsetEndSpinner.Tag="PreProcessingSubsetEndSpinner";
            this.subsetEndSpinner.Description=getString(message('MATLAB:datatools:preprocessing:app:PPMODE_SUBSET_END_DESCRIPTION'));
            this.subsetStepSpinner=Spinner([1,1000000000],1);
            this.subsetStepSpinner.Tag="PreProcessingSubsetStepSpinner";
            this.subsetStepSpinner.Description=getString(message('MATLAB:datatools:preprocessing:app:PPMODE_SUBSET_STEP_DESCRIPTION'));

            subsetValuesColumn.add(this.subsetStartSpinner);
            subsetValuesColumn.add(this.subsetEndSpinner);
            subsetValuesColumn.add(this.subsetStepSpinner);
        end

        function createPreprocessingModeGallery(this,tab,preprocessingLiveTasks)
            import matlab.ui.internal.toolstrip.*


            preprocSection=tab.addSection(getString(message('MATLAB:datatools:preprocessing:app:PPTaskGroupTitle')));
            preprocSection.Tag="Pre Processing Section";
            preprocColumn=preprocSection.addColumn();

            this.PreprocessingGalleryPopup=GalleryPopup();
            this.PreprocessingGalleryPopup.Tag='preprocGalleryPopup';

            this.PreprocessingGalleryItems=containers.Map;
            this.PreprocessingGalleryCategories=containers.Map;
            for i=1:length(preprocessingLiveTasks)
                task=preprocessingLiveTasks(i);
                this.addGalleryItem(task);
            end

            this.PreprocessingGallery=Gallery(this.PreprocessingGalleryPopup...
            ,'MaxColumnCount',this.DEFAULT_PPMODE_GALLERY_MAX_COLS...
            ,'MinColumnCount',this.DEFAULT_PPMODE_GALLERY_MIN_COLS...
            );
            this.PreprocessingGallery.Tag="operationsGallery";
            this.PreprocessingGallery.Enabled=false;
            preprocColumn.add(this.PreprocessingGallery);
        end



        function setPreprocessingModeTabTitle(this,title)
            this.PreprocessingTab.Title=title;
        end

        function addGalleryItem(this,task)
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.*;
            import matlab.ui.internal.toolstrip.*

            taskItem=GalleryItem(task.Name,task.Icon);
            taskItem.Tag=task.Name;
            taskItem.Description=task.Description;

            category=this.getTaskCategory(task);
            category.add(taskItem);
            this.PreprocessingGalleryItems(task.Name)=taskItem;
        end

        function removeGalleryItem(this,task)
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.*;
            import matlab.ui.internal.toolstrip.*

            category=this.getTaskCategory(task);
            taskItem=category.getChildByTag(task.Name);

            category.remove(taskItem);
            this.PreprocessingGalleryItems(task.Name)=[];
        end

        function addCustomCategory(this)
            import matlab.ui.internal.*;
            import matlab.ui.internal.toolstrip.*

            customCategory=matlab.ui.internal.toolstrip.GalleryCategory(...
            getString(message('MATLAB:datatools:preprocessing:app:CUSTOM_CATEGORY')));

            this.AddCustomFunctionButton=matlab.ui.internal.toolstrip.GalleryItem(...
            getString(message('MATLAB:datatools:preprocessing:app:ADD_CUSTOM_FUNCTION')),...
            Icon.ADD_24);
            customCategory.add(this.AddCustomFunctionButton);

            editIconPath=fullfile(matlabroot,'toolbox','matlab','datatools','preprocessing','resources','edit_16.png');
            this.EditCustomFunctionButton=matlab.ui.internal.toolstrip.GalleryItem(...
            getString(message('MATLAB:datatools:preprocessing:app:EDIT_CUSTOM_FUNCTION')),...
            Icon(editIconPath));
            customCategory.add(this.EditCustomFunctionButton);

            this.PreprocessingGalleryCategories(...
            getString(message('MATLAB:datatools:preprocessing:app:CUSTOM_CATEGORY')))=customCategory;
            this.PreprocessingGalleryItems(...
            getString(message('MATLAB:datatools:preprocessing:app:ADD_CUSTOM_FUNCTION')))=...
            this.AddCustomFunctionButton;
            this.PreprocessingGalleryItems(...
            getString(message('MATLAB:datatools:preprocessing:app:EDIT_CUSTOM_FUNCTION')))=...
            this.EditCustomFunctionButton;
            this.PreprocessingGalleryPopup.add(customCategory);
        end

        function addColumnTransformationButton(this)
            import matlab.ui.internal.*;
            import matlab.ui.internal.toolstrip.*

            cleaningCategory=this.PreprocessingGalleryCategories(...
            getString(message('MATLAB:datatools:preprocessing:app:TASK_GROUP_CLEANING')));

            this.ColumnTransformationButton=matlab.ui.internal.toolstrip.GalleryItem(...
            getString(message('MATLAB:datatools:preprocessing:app:TASK_COLUMN_TRANSFORM_BUTTON_TEXT')),...
            fullfile(matlabroot,'toolbox','matlab','datatools','preprocessing','+matlab','+internal','+preprocessingApp','+images/','computeColumn_24.png'));
            this.ColumnTransformationButton.Description=getString(message('MATLAB:datatools:preprocessing:app:TASK_COLUMN_TRANSFORM_BUTTON_DESCRIPTION'));
            cleaningCategory.add(this.ColumnTransformationButton);

            this.PreprocessingGalleryItems(...
            getString(message('MATLAB:datatools:preprocessing:app:TASK_COLUMN_TRANSFORM_BUTTON_TEXT')))=...
            this.ColumnTransformationButton;
        end

        function category=getTaskCategory(this,task)
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.*;
            import matlab.ui.internal.toolstrip.*

            if~isKey(this.PreprocessingGalleryCategories,task.Group)
                category=GalleryCategory(task.Group);
                category.Tag=task.Group+"Category";
                this.PreprocessingGalleryPopup.add(category);
            else
                category=this.PreprocessingGalleryCategories(task.Group);
            end
            this.PreprocessingGalleryCategories(task.Group)=category;
        end

        function importWorkspace=getImportWorkspaceButton(this)
            importWorkspace=this.ImportButton.Popup.getChildByTag(this.IMPORT_WORKSPACE_TAG);
        end

        function importFile=getImportFileButton(this)
            importFile=this.ImportButton.Popup.getChildByTag(this.IMPORT_FILE_TAG);
        end

        function exportWorkspace=getExportWorkspaceButton(this)
            exportWorkspace=this.ExportButton.Popup.getChildByTag(this.EXPORT_WORKSPACE_TAG);
        end

        function exportScript=getExportScriptButton(this)
            exportScript=this.ExportButton.Popup.getChildByTag(this.EXPORT_SCRIPT_TAG);
        end

        function exportFunction=getExportFunctionButton(this)
            exportFunction=this.ExportButton.Popup.getChildByTag(this.EXPORT_FUNCTION_TAG);
        end

        function delete(this)


            delete(this.PreprocessingGallery);
        end
    end
end

