classdef ConstraintsDialogSchema<handle




    properties(SetAccess=private,GetAccess=public)

        ConstrSSSrc slvariants.internal.manager.ui.config.VariantConstraintSource;

        ConfigCatalogCacheWrapper slvariants.internal.manager.ui.config.VariantConfigurationsCacheWrapper;

        VariantConfigs(1,1)Simulink.VariantConfigurationData;

        IsHierarchy=false;

        IsStandalone=false;

        BDHandle;

        ConfigObjVarName='';

        SelectedConstraintIdx=1;

        ShowInfo=true;

        StatusFlagForWidgets=true;
    end

    properties(Dependent,SetAccess=private,GetAccess=public)
        BDName;

        TagId;
    end

    methods

        function obj=ConstraintsDialogSchema(sourceCacheObj,isStandalone,nameOrHandle)
            obj.ConfigCatalogCacheWrapper=sourceCacheObj;
            obj.VariantConfigs=sourceCacheObj.VariantConfigurationCatalogCache;
            obj.ConstrSSSrc=slvariants.internal.manager.ui.config.VariantConstraintSource(obj.VariantConfigs,'',obj,true);
            obj.IsStandalone=isStandalone;

            if isStandalone
                obj.ConfigObjVarName=nameOrHandle;
            else
                obj.BDHandle=nameOrHandle;
            end
        end

        function tagId=get.TagId(obj)
            if(obj.IsStandalone)
                tagId=obj.ConfigObjVarName;
            else
                tagId=getfullname(obj.BDHandle);
            end
        end

        function bdName=get.BDName(obj)
            if(obj.IsStandalone)
                bdName='';
            else
                bdName=getfullname(obj.BDHandle);
            end
        end

        function setCacheObjDirtyFlag(obj)

            if obj.IsStandalone
                return;
            end
            import slvariants.internal.manager.ui.config.findDDGByTagIdAndTag;
            configsDlg=findDDGByTagIdAndTag(obj.TagId,'configurationsDialogSchemaTag');
            if isempty(configsDlg)




                return;
            end
            configSchema=configsDlg.getSource();
            configSchema.setSourceObjDirtyFlag(configSchema);
        end

        function refreshGlobalConstraints(obj,dlg)

            if obj.IsStandalone
                return;
            end
            obj.VariantConfigs=obj.ConfigCatalogCacheWrapper.VariantConfigurationCatalogCache;
            obj.ConstrSSSrc=slvariants.internal.manager.ui.config.VariantConstraintSource(obj.VariantConfigs,'',obj);

            obj.SelectedConstraintIdx=1;

            dlg.refresh();

            isDirty=false;
            obj.updateConstrDialog(dlg,obj,isDirty);
        end

        function saveCacheToVariantConfigurationCatalog(obj)


            obj.ConfigCatalogCacheWrapper.saveCacheToVariantConfigurationCatalog();
        end

        function constraintConditionEdited(obj,newValue)
            constraintRow=obj.ConstrSSSrc.Children(obj.SelectedConstraintIdx);
            constraintRow.setPropValue(slvariants.internal.manager.ui.config.VMgrConstants.Constraint,newValue);
        end

        function constraintDescriptionEdited(obj,newValue)
            constraintRow=obj.ConstrSSSrc.Children(obj.SelectedConstraintIdx);
            constraintRow.setPropValue(slvariants.internal.manager.ui.config.VMgrConstants.Description,newValue);
        end

        function det=getConstraintDetails(obj)
            if isempty(obj.VariantConfigs.getGlobalConstraintNames)
                det.Name='';
                det.Condition='';
                det.Description='';
            else
                constraintRow=obj.ConstrSSSrc.Children(obj.SelectedConstraintIdx);
                det.Name=obj.VariantConfigs.getGlobalConstraintNames{obj.SelectedConstraintIdx};
                det.Condition=constraintRow.getPropValue(slvariants.internal.manager.ui.config.VMgrConstants.Constraint);
                det.Description=constraintRow.getPropValue(slvariants.internal.manager.ui.config.VMgrConstants.Description);
            end
        end

        function infoCloseButtonClicked(obj,dlg)
            obj.ShowInfo=false;
            dlg.setVisible('constraintHintTag',false);
        end



        function dlgstruct=getDialogSchema(obj,~)

            obj.populateStatusFlagForWidgets();

            obj.ConstrSSSrc.getChildren;

            dlgstruct.DialogTitle='';
            dlgstruct.DialogTag='constraintsDialogSchemaTag';
            dlgstruct.Source=obj.ConstrSSSrc;
            dlgstruct.DialogMode='Slim';
            dlgstruct.Items={obj.getListOfConstraintsPanel,obj.getConstraintDefinitionPanel};
            dlgstruct.LayoutGrid=[2,1];
            dlgstruct.RowStretch=[0,1];
            dlgstruct.OpenCallback=@obj.openCB;
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.Spacing=0;
        end

        function listOfConstraintsPanel=getListOfConstraintsPanel(obj)
            listOfConstraintsPanel.Name=slvariants.internal.manager.ui.config.VMgrConstants.ConstraintList;
            listOfConstraintsPanel.Type='panel';
            listOfConstraintsPanel.LayoutGrid=[1,2];
            listOfConstraintsPanel.Expand=true;
            listOfConstraintsPanel.Items={obj.getConstraintButtonsPanelStruct,obj.getListOfConstraintsList};
            listOfConstraintsPanel.RowSpan=[1,1];
            listOfConstraintsPanel.ColSpan=[1,1];
        end

        function listOfConstraintsList=getListOfConstraintsList(obj)
            listOfConstraintsList.Type='spreadsheet';
            listOfConstraintsList.Tag='globalConstraintsSSWidgetTag';
            listOfConstraintsList.Columns={...
            slvariants.internal.manager.ui.config.VMgrConstants.Name};
            listOfConstraintsList.Config='{"hidecolumns":true}';
            listOfConstraintsList.RowSpan=[2,2];
            listOfConstraintsList.ColSpan=[1,1];
            listOfConstraintsList.MinimumSize=[100,150];
            listOfConstraintsList.PreferredSize=[250,150];
            listOfConstraintsList.MaximumSize=[10000,150];
            listOfConstraintsList.Enabled=true;
            listOfConstraintsList.Source=obj.ConstrSSSrc;
            listOfConstraintsList.DialogRefresh=true;
            listOfConstraintsList.Mode=true;
            listOfConstraintsList.SelectionChangedCallback=@obj.constrSelectionChanged;
        end

        function constraintsDefinitionPanel=getConstraintDefinitionPanel(obj)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            constraintDetails=obj.getConstraintDetails;

            if isempty(constraintDetails.Name)
                constraintsDefinitionPanel.Enabled=false;
            else
                constraintsDefinitionPanel.Enabled=true;
            end
            constraintsDefinitionPanel.Name=VMgrConstants.ConstraintDefinition;
            constraintsDefinitionPanel.Type='togglepanel';
            constraintsDefinitionPanel.Tag='constraintDefinitionTag';
            constraintsDefinitionPanel.LayoutGrid=[4,1];
            constraintsDefinitionPanel.Expand=true;
            constraintsDefinitionPanel.RowStretch=[0,0,1,1];
            constraintsDefinitionPanel.Items={obj.getConstraintNameTextBox,...
            obj.getContextHelp,...
            obj.getConditionPanel,...
            obj.getDescriptionPanel};
            constraintsDefinitionPanel.RowSpan=[2,2];
            constraintsDefinitionPanel.ColSpan=[1,1];
            constraintsDefinitionPanel.WidgetId='constraintDefinitionID';
        end

        function constrNameText=getConstraintNameTextBox(obj)
            constraintDetails=obj.getConstraintDetails;

            constrNameText.Type='text';
            constrNameText.Name=constraintDetails.Name;
            constrNameText.Tag='constraintNameTag';
            constrNameText.ColSpan=[1,1];
            constrNameText.RowSpan=[1,1];
            constrNameText.Bold=true;
            constrNameText.FontPointSize=10;
        end

        function conditionPanel=getConditionPanel(obj)
            constraintDetails=obj.getConstraintDetails;

            conditionLbl.Type='text';
            conditionLbl.Name=slvariants.internal.manager.ui.config.VMgrConstants.ConstraintCondition;
            conditionLbl.Tag='constraintConditionLblTag';
            conditionLbl.ColSpan=[1,1];
            conditionLbl.RowSpan=[1,1];
            conditionLbl.Bold=true;
            conditionLbl.Alignment=2;

            condition.Type='editarea';
            condition.DialogRefresh=false;
            condition.Mode=true;
            condition.MatlabMethod='constraintConditionEdited';
            condition.Tag='constraintConditionTag';
            conditionLbl.Buddy=condition.Tag;
            condition.MatlabArgs={obj,'%value'};
            condition.ColSpan=[1,1];
            condition.RowSpan=[2,2];
            condition.Value=constraintDetails.Condition;
            condition.MinimumSize=[100,100];
            condition.PreferredSize=[200,100];
            condition.MaximumSize=[5000,5000];
            condition.WordWrap=true;
            condition.Enabled=obj.StatusFlagForWidgets;

            conditionPanel.Type='panel';
            conditionPanel.ColSpan=[1,1];
            conditionPanel.RowSpan=[3,3];
            conditionPanel.LayoutGrid=[2,1];
            conditionPanel.Items={conditionLbl,condition};
            conditionPanel.Alignment=0;
            conditionPanel.RowStretch=[0,1];
        end

        function descriptionPanel=getDescriptionPanel(obj)
            constraintDetails=obj.getConstraintDetails;

            descriptionLbl.Type='text';
            descriptionLbl.Name=slvariants.internal.manager.ui.config.VMgrConstants.ConstraintDescription;
            descriptionLbl.ColSpan=[1,1];
            descriptionLbl.RowSpan=[1,1];
            descriptionLbl.Bold=true;
            descriptionLbl.Alignment=2;

            description.Type='editarea';
            description.Value=constraintDetails.Description;
            description.DialogRefresh=false;
            description.Mode=true;
            description.MatlabMethod='constraintDescriptionEdited';
            description.Tag='constraintDescriptionTag';
            descriptionLbl.Buddy=description.Tag;
            description.MatlabArgs={obj,'%value'};
            description.ColSpan=[1,1];
            description.RowSpan=[2,2];
            description.MinimumSize=[100,100];
            description.PreferredSize=[200,100];
            description.MaximumSize=[5000,5000];
            description.WordWrap=true;
            description.Enabled=obj.StatusFlagForWidgets;

            descriptionPanel.Type='panel';
            descriptionPanel.ColSpan=[1,1];
            descriptionPanel.RowSpan=[4,4];
            descriptionPanel.LayoutGrid=[2,1];
            descriptionPanel.Items={descriptionLbl,description};
            descriptionPanel.Alignment=0;
            descriptionPanel.RowStretch=[0,1];
        end

        function contextHelp=getContextHelp(obj)

            import slvariants.internal.manager.ui.config.VMgrConstants;

            infoIcon.Type='image';
            infoIcon.ColSpan=[1,1];
            infoIcon.RowSpan=[1,1];
            infoIcon.FilePath=VMgrConstants.InfoIcon;
            infoIcon.Alignment=2;
            infoIcon.Tag='constraintHintInfoIconTag';

            infoMessage.Type='text';
            infoMessage.Name=slvariants.internal.manager.ui.config.VMgrConstants.ConstraintInfoMssg;
            infoMessage.ColSpan=[2,59];
            infoMessage.RowSpan=[1,1];
            infoMessage.WordWrap=true;
            infoMessage.FontPointSize=4;
            infoMessage.ForegroundColor=[50,50,50];
            infoMessage.Tag='constraintHintInfoMsgTag';

            infoCloseButton.Type='image';
            infoCloseButton.ColSpan=[60,60];
            infoCloseButton.RowSpan=[1,1];
            infoCloseButton.FilePath=VMgrConstants.CloseIcon;
            infoCloseButton.Alignment=4;
            infoCloseButton.Tag='constraintHintCloseIconTag';
            infoCloseButton.MatlabMethod='infoCloseButtonClicked';
            infoCloseButton.MatlabArgs={obj,'%dialog'};

            contextHelp.Type='panel';
            contextHelp.Tag='constraintHintTag';
            contextHelp.LayoutGrid=[1,60];
            contextHelp.ColSpan=[1,1];
            contextHelp.RowSpan=[2,2];
            contextHelp.BackgroundColor=[240,240,240];
            contextHelp.Items={infoIcon,infoMessage,infoCloseButton};
        end

        function spacer=createSpacer(~,rowIdx,colIdx)
            spacer.Name='';
            spacer.Type='text';
            spacer.RowSpan=[rowIdx,rowIdx];
            spacer.ColSpan=[colIdx,colIdx];
        end

        function addButton=getAddConstraintButtonStruct(obj)


            import slvariants.internal.manager.ui.config.VMgrConstants
            addButton.ToolTip=VMgrConstants.AddConstraintButtonToolTip;
            addButton.FilePath=VMgrConstants.AddRowIcon;
            addButton.Type='pushbutton';
            addButton.Tag='addConstraintButtonTag';
            addButton.RowSpan=[1,1];
            addButton.ColSpan=[1,1];
            addButton.MatlabMethod='slvariants.internal.manager.ui.config.ConstraintsDialogSchema.addConstraintCB';
            addButton.MatlabArgs={'%dialog',obj};
            addButton.MaximumSize=[25,25];
        end

        function deleteButton=getDeleteConstraintButtonStruct(obj)


            import slvariants.internal.manager.ui.config.VMgrConstants
            deleteButton.ToolTip=VMgrConstants.DeleteConstraintButtonToolTip;
            deleteButton.FilePath=VMgrConstants.DeleteRowIcon;
            deleteButton.Type='pushbutton';
            deleteButton.Tag='deleteConstraintButtonTag';
            deleteButton.RowSpan=[1,1];
            deleteButton.ColSpan=[3,3];
            deleteButton.MatlabMethod='slvariants.internal.manager.ui.config.ConstraintsDialogSchema.deleteConstraintCB';
            deleteButton.MatlabArgs={'%dialog',obj};
            deleteButton.MaximumSize=[25,25];
            deleteButton.Enabled=false;
        end

        function copyButton=getCopyConstraintButtonStruct(obj)


            import slvariants.internal.manager.ui.config.VMgrConstants
            copyButton.ToolTip=VMgrConstants.CopyConstraintButtonToolTip;
            copyButton.FilePath=VMgrConstants.CopyRowIcon;
            copyButton.Type='pushbutton';
            copyButton.Tag='copyConstraintButtonTag';
            copyButton.RowSpan=[1,1];
            copyButton.ColSpan=[2,2];
            copyButton.MatlabMethod='slvariants.internal.manager.ui.config.ConstraintsDialogSchema.copyConstraintCB';
            copyButton.MatlabArgs={'%dialog',obj};
            copyButton.MaximumSize=[25,25];
            copyButton.Enabled=false;
        end

        function constraintButtonsPanel=getConstraintButtonsPanelStruct(obj)


            constraintButtonsPanel.Name='constraintsButtonsPanel';
            constraintButtonsPanel.Type='panel';
            constraintButtonsPanel.Items={obj.getAddConstraintButtonStruct(),...
            obj.getCopyConstraintButtonStruct(),...
            obj.getDeleteConstraintButtonStruct(),...
            obj.createSpacer(1,4)};
            constraintButtonsPanel.Tag='constraintButtonsPanelTag';
            constraintButtonsPanel.LayoutGrid=[1,4];
            constraintButtonsPanel.RowSpan=[1,1];
            constraintButtonsPanel.ColSpan=[1,1];
            constraintButtonsPanel.Visible=true;


            constraintButtonsPanel.Visible=obj.StatusFlagForWidgets;
            constraintButtonsPanel.Enabled=obj.StatusFlagForWidgets;
        end
    end

    methods(Static)

        function addNewConstraint(varConstrSrc,newConstr)
            import slvariants.internal.manager.ui.config.VariantConstraintRow;
            constraintNames=varConstrSrc.getConstraintNames();
            varConstrSrc.VariantConfigs.addGlobalConstraintByName(newConstr.Name);
            varConstrSrc.VariantConfigs.setGlobalConstraintDescription(newConstr.Name,newConstr.Description);
            varConstrSrc.VariantConfigs.setGlobalConstraintCondition(newConstr.Name,newConstr.Condition);
            varConstrSrc.Children(end+1)=...
            VariantConstraintRow(varConstrSrc,...
            newConstr.Name,numel(constraintNames)+1);
        end

        function openCB(dlg)
            constrSSInterface=dlg.getWidgetInterface('globalConstraintsSSWidgetTag');
            constrSSInterface.setEmptyListMessage(slvariants.internal.manager.ui.config.VMgrConstants.ConstraintListPlaceholder);
        end

        function addConstraintCB(dlg,obj)
            varConstrSrc=obj.ConstrSSSrc;
            constraintNames=varConstrSrc.getConstraintNames();


            newConstr=slvariants.internal.config.types.getConstraintStruct();
            newConstr.Name=matlab.lang.makeUniqueStrings('Constraint',constraintNames);
            obj.addNewConstraint(varConstrSrc,newConstr);

            dirtyFlag=true;
            obj.updateConstrDialog(dlg,obj,dirtyFlag);

            constrSSInterface=dlg.getWidgetInterface('globalConstraintsSSWidgetTag');
            constrSSInterface.select(varConstrSrc.Children(end));
            dlg.setWidgetDirty('globalConstraintsSSWidgetTag');
            dlg.enableApplyButton(true);
        end

        function deleteConstraintCB(dlg,obj)

            varConstrSrc=obj.ConstrSSSrc;
            constrSSInterface=dlg.getWidgetInterface('globalConstraintsSSWidgetTag');
            selectedRows=constrSSInterface.getSelection();
            if isempty(selectedRows)
                return;
            end
            constrIdx=selectedRows{1}.VarConstrIdx;

            if constrIdx==numel(varConstrSrc.getConstraintNames())&&constrIdx~=1
                obj.SelectedConstraintIdx=constrIdx-1;
            end


            varConstrSrc.VariantConfigs.removeGlobalConstraintByPos(constrIdx);
            varConstrSrc.Children(constrIdx)=[];
            varConstrSrc.fixIndices(constrIdx);

            dirtyFlag=true;
            obj.updateConstrDialog(dlg,obj,dirtyFlag);

            constrSSInterface=dlg.getWidgetInterface('globalConstraintsSSWidgetTag');
            if constrIdx==1
                if numel(obj.ConstrSSSrc.getConstraintNames())>0
                    constrSSInterface.select(obj.ConstrSSSrc.Children(constrIdx));
                end
            else
                constrSSInterface.select(obj.ConstrSSSrc.Children(constrIdx-1));
            end
            dlg.setWidgetDirty('globalConstraintsSSWidgetTag');
            dlg.enableApplyButton(true);
        end

        function copyConstraintCB(dlg,obj)
            import slvariants.internal.manager.ui.config.VariantConstraintRow;

            varConstrSrc=obj.ConstrSSSrc;
            constraintNames=varConstrSrc.getConstraintNames();
            constrSSInterface=dlg.getWidgetInterface('globalConstraintsSSWidgetTag');
            selectedRows=constrSSInterface.getSelection();
            if isempty(selectedRows)
                return;
            end
            constrIdx=selectedRows{1}.VarConstrIdx;




            newName=matlab.lang.makeUniqueStrings(selectedRows{1}.Name,constraintNames);
            varConstrSrc.VariantConfigs.copyGlobalConstraintByPos(constrIdx,newName);
            copiedRow=VariantConstraintRow(varConstrSrc,newName,constrIdx+1);
            varConstrSrc.Children=[varConstrSrc.Children(1:constrIdx),copiedRow,varConstrSrc.Children(constrIdx+1:end)];
            varConstrSrc.fixIndices(constrIdx+2);

            dirtyFlag=true;
            obj.updateConstrDialog(dlg,obj,dirtyFlag);

            constrSSInterface=dlg.getWidgetInterface('globalConstraintsSSWidgetTag');
            constrSSInterface.select(obj.ConstrSSSrc.Children(constrIdx+1));
            dlg.setWidgetDirty('globalConstraintsSSWidgetTag');
            dlg.enableApplyButton(true);
        end

        function dummyOut=constrSelectionChanged(~,items,dlg,~)

            dummyOut=true;
            if numel(items)==1
                dlg.setEnabled('deleteConstraintButtonTag',true);
                dlg.setEnabled('copyConstraintButtonTag',true);
            else

                dlg.setEnabled('deleteConstraintButtonTag',false);
                dlg.setEnabled('copyConstraintButtonTag',false);
            end
            if isempty(items)
                return;
            end
            listIdx=items{1}.VarConstrIdx;
            varConstrSSSrc=items{1}.VarConstrSSSrc;
            constraintCount=length(varConstrSSSrc.VariantConfigs.getGlobalConstraintNames());
            constrDlgSchema=varConstrSSSrc.DialogSchema;
            selectedIdx=constrDlgSchema.SelectedConstraintIdx;
            if listIdx>constraintCount||listIdx==selectedIdx
                return;
            end
            constrDlgSchema.SelectedConstraintIdx=listIdx;
            dirtyFlag=false;
            constrDlgSchema.updateConstrDialog(dlg,constrDlgSchema,dirtyFlag);
        end

        function updateConstrDialog(dlg,obj,dirtyFlag)

            import slvariants.internal.manager.ui.config.VariantConstraintSource;
            import slvariants.internal.manager.ui.config.ConfigurationsDialogSchema;

            obj.setCacheObjDirtyFlag();


            ConfigurationsDialogSchema.callUpdateOnSpreadsheet(...
            dlg,'globalConstraintsSSWidgetTag');

            constraintDetails=obj.getConstraintDetails;

            dlg.setEnabled('constraintDefinitionTag',~isempty(constraintDetails.Name));


            dlg.setWidgetValue('constraintNameTag',constraintDetails.Name);
            if~dlg.isWidgetDirty('constraintNameTag')&&~dirtyFlag
                dlg.clearWidgetDirtyFlag('constraintNameTag');
            end


            dlg.setWidgetValue('constraintConditionTag',constraintDetails.Condition);
            if~dlg.isWidgetDirty('constraintConditionTag')&&~dirtyFlag
                dlg.clearWidgetDirtyFlag('constraintConditionTag');
            end


            dlg.setWidgetValue('constraintDescriptionTag',constraintDetails.Description);
            if~dlg.isWidgetDirty('constraintDescriptionTag')&&~dirtyFlag
                dlg.clearWidgetDirtyFlag('constraintDescriptionTag');
            end
        end
    end

    methods(Access=private)
        function populateStatusFlagForWidgets(obj)
            import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;
            import slvariants.internal.manager.ui.config.findDDGByTagIdAndTag;
            configsDlg=findDDGByTagIdAndTag(obj.TagId,'configurationsDialogSchemaTag');
            if isempty(configsDlg)


                obj.StatusFlagForWidgets=true;
            else
                configSchema=configsDlg.getSource();
                obj.StatusFlagForWidgets=configSchema.ReduceAnalyzeModeFlag==ReduceAnalyzeModes.Unset;
            end
        end
    end
end


