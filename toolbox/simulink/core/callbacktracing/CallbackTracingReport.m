classdef CallbackTracingReport<handle

    properties
        m_modelName;
        m_modelHandle;
        m_CallReportSpreadsheet;
        m_ModelNameChangedListner;
    end

    methods

        function obj=CallbackTracingReport(modelName)
            obj.m_modelName=modelName;
            obj.m_modelHandle=get_param(modelName,'Handle');
            obj.m_CallReportSpreadsheet=Simulink.CallbackTracingReportSpreadsheet(obj.m_modelName);
            Simulink.addBlockDiagramCallback(obj.m_modelHandle,'PreClose',...
            'CallbackTracing',...
            @()CallbackTracing('Delete',obj.m_modelName),true);

            bdCosObj=get_param(obj.m_modelHandle,'InternalObject');
            obj.m_ModelNameChangedListner=addlistener(bdCosObj,...
            'SLGraphicalEvent::NAME_CHANGE_MODEL_EVENT',...
            @(src,evnt)obj.onModelNameChanged(src,evnt,'',''));
        end

        function dlgstruct=getDialogSchema(obj)


            filterIncludeMWLibraryCallbacks.Type='checkbox';
            filterIncludeMWLibraryCallbacks.Name=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolMWInternalFilter');
            filterIncludeMWLibraryCallbacks.ToolTip=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolMWInternalFilterTooltip');
            filterIncludeMWLibraryCallbacks.Tag='FilterIncludeMWLibraryCallbacks';
            filterIncludeMWLibraryCallbacks.RowSpan=[1,1];
            filterIncludeMWLibraryCallbacks.ColSpan=[1,1];
            filterIncludeMWLibraryCallbacks.MatlabMethod='CallbackTracingReport_Callbacks';
            filterIncludeMWLibraryCallbacks.MatlabArgs={'%dialog','%tag',obj};
            filterIncludeMWLibraryCallbacks.DialogRefresh=true;


            includeGroup.Type='group';
            includeGroup.Name=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolIncludeGroupTitle');
            includeGroup.Tag='includeGroup';
            includeGroup.Enabled=true;
            includeGroup.Items={filterIncludeMWLibraryCallbacks};
            includeGroup.LayoutGrid=[1,1];
            includeGroup.RowSpan=[1,1];
            includeGroup.ColSpan=[1,1];


            filterBlockCallbacks.Type='checkbox';
            filterBlockCallbacks.Name=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolBlockFilter');
            filterBlockCallbacks.Tag='FilterBlockCallbacks';
            filterBlockCallbacks.RowSpan=[1,1];
            filterBlockCallbacks.ColSpan=[1,1];
            filterBlockCallbacks.MatlabMethod='CallbackTracingReport_Callbacks';
            filterBlockCallbacks.MatlabArgs={'%dialog','%tag',obj};
            filterBlockCallbacks.DialogRefresh=true;


            filterModelCallbacks.Type='checkbox';
            filterModelCallbacks.Name=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolModelFilter');
            filterModelCallbacks.Tag='FilterModelCallbacks';
            filterModelCallbacks.RowSpan=[2,2];
            filterModelCallbacks.ColSpan=[1,1];
            filterModelCallbacks.MatlabMethod='CallbackTracingReport_Callbacks';
            filterModelCallbacks.MatlabArgs={'%dialog','%tag',obj};
            filterModelCallbacks.DialogRefresh=true;


            filterPortCallbacks.Type='checkbox';
            filterPortCallbacks.Name=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolPortFilter');
            filterPortCallbacks.Tag='FilterPortCallbacks';
            filterPortCallbacks.RowSpan=[3,3];
            filterPortCallbacks.ColSpan=[1,1];
            filterPortCallbacks.MatlabMethod='CallbackTracingReport_Callbacks';
            filterPortCallbacks.MatlabArgs={'%dialog','%tag',obj};
            filterPortCallbacks.DialogRefresh=true;


            filterMaskInitCallbacks.Type='checkbox';
            filterMaskInitCallbacks.Name=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolMaskInitFilter');
            filterMaskInitCallbacks.Tag='FilterMaskInitCallbacks';
            filterMaskInitCallbacks.RowSpan=[1,1];
            filterMaskInitCallbacks.ColSpan=[2,2];
            filterMaskInitCallbacks.MatlabMethod='CallbackTracingReport_Callbacks';
            filterMaskInitCallbacks.MatlabArgs={'%dialog','%tag',obj};
            filterMaskInitCallbacks.DialogRefresh=true;


            filterMaskParameterCallbacks.Type='checkbox';
            filterMaskParameterCallbacks.Name=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolMaskParameterFilter');
            filterMaskParameterCallbacks.Tag='FilterMaskParameterCallbacks';
            filterMaskParameterCallbacks.RowSpan=[2,2];
            filterMaskParameterCallbacks.ColSpan=[2,2];
            filterMaskParameterCallbacks.MatlabMethod='CallbackTracingReport_Callbacks';
            filterMaskParameterCallbacks.MatlabArgs={'%dialog','%tag',obj};
            filterMaskParameterCallbacks.DialogRefresh=true;


            filterGroup.Type='group';
            filterGroup.Name=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolShowGroupTitle');
            filterGroup.Tag='filterGroup';
            filterGroup.Enabled=true;
            filterGroup.Items={filterBlockCallbacks,filterModelCallbacks,...
            filterPortCallbacks,filterMaskInitCallbacks,filterMaskParameterCallbacks};
            filterGroup.LayoutGrid=[3,3];
            filterGroup.RowSpan=[2,2];
            filterGroup.ColSpan=[1,1];


            includeAndFilterPanel.Type='panel';
            includeAndFilterPanel.LayoutGrid=[2,1];
            includeAndFilterPanel.RowSpan=[1,1];
            includeAndFilterPanel.ColSpan=[1,1];
            includeAndFilterPanel.Items={includeGroup,filterGroup};
            includeAndFilterPanel.Tag='topPanel';


            clearButton.Name=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolClearLogButton');
            clearButton.Type='pushbutton';
            clearButton.RowSpan=[1,1];
            clearButton.Enabled=true;
            clearButton.ColSpan=[1,1];
            clearButton.ToolTip=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolClearLogButtonTooltip');
            clearButton.Tag='ClearCallbackLogButton';
            clearButton.MatlabMethod='CallbackTracingReport_Callbacks';
            clearButton.MatlabArgs={'%dialog','%tag',obj};


            exportButton.Name=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolExportButton');
            exportButton.Type='pushbutton';
            exportButton.RowSpan=[2,2];
            exportButton.ColSpan=[1,1];
            exportButton.ToolTip=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolExportButtonTooltip');
            exportButton.Enabled=true;
            exportButton.Tag='CallbackTracingExportButton';
            exportButton.MatlabMethod='CallbackTracingReport_Callbacks';
            exportButton.MatlabArgs={'%dialog','%tag',obj};


            helpButton.Name=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolHelpButton');
            helpButton.Type='pushbutton';
            helpButton.RowSpan=[3,3];
            helpButton.ColSpan=[1,1];
            helpButton.Tag='CallbackTracingHelpButton';
            helpButton.MatlabMethod='CallbackTracingReport_Callbacks';
            helpButton.MatlabArgs={'%dialog','%tag',obj};


            buttonPanel.Type='panel';
            buttonPanel.LayoutGrid=[3,1];
            buttonPanel.Items={exportButton,clearButton,helpButton};
            buttonPanel.Tag='ButtonPanel';
            buttonPanel.RowSpan=[1,1];
            buttonPanel.ColSpan=[3,3];
            buttonPanel.Alignment=6;


            spacer.Type='panel';
            spacer.RowSpan=[1,1];
            spacer.ColSpan=[2,2];


            topPanel.Type='panel';
            topPanel.LayoutGrid=[1,3];
            topPanel.Items={includeAndFilterPanel,spacer,buttonPanel};
            topPanel.Tag='topPanel';
            topPanel.ColStretch=[3,1,0];


            spreadsheetFilter.Type='spreadsheetfilter';
            spreadsheetFilter.RowSpan=[1,1];
            spreadsheetFilter.ColSpan=[2,2];
            spreadsheetFilter.Enabled=true;
            spreadsheetFilter.Tag='CallbackTracingReportSpreadsheetFilter';
            spreadsheetFilter.TargetSpreadsheet='CallbackTracingReportSpreadsheet';
            spreadsheetFilter.PlaceholderText=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolSpreadsheetFilterText');
            spreadsheetFilter.Clearable=true;


            stageNameList.Type='combobox';
            stageNameList.Tag='CallbackTracingStageNameList';
            stageNameList.Entries=obj.getStageNames;
            stageNameList.Mode=1;
            stageNameList.RowSpan=[1,1];
            stageNameList.ColSpan=[1,1];
            stageNameList.MinimumSize=[300,20];
            stageNameList.Graphical=true;
            stageNameList.Enabled=true;
            stageNameList.DialogRefresh=true;
            stageNameList.MatlabMethod='CallbackTracingReport_Callbacks';
            stageNameList.MultiSelect=false;
            stageNameList.MatlabArgs={'%dialog','%tag','%value',obj,'CallbackTracingReportSpreadsheet'};


            searchAndStagePanel.Type='panel';
            searchAndStagePanel.LayoutGrid=[1,2];
            searchAndStagePanel.Items={stageNameList,spreadsheetFilter};
            searchAndStagePanel.Tag='SpreadsheetSearchAndFilterPanel';


            bCallReportTable.Type='spreadsheet';
            bCallReportTable.Source=obj.m_CallReportSpreadsheet;
            bCallReportTable.Columns=obj.getColumns;
            bCallReportTable.UserData=obj.m_CallReportSpreadsheet;
            bCallReportTable.Enabled=true;
            bCallReportTable.Editable=1;
            bCallReportTable.Tag='CallbackTracingReportSpreadsheet';
            bCallReportTable.SortColumn=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolSerialNoColumnName');
            bCallReportTable.SortOrder=true;


            callbackDataGroup.Type='panel';
            callbackDataGroup.Name='';
            callbackDataGroup.LayoutGrid=[1,1];
            callbackDataGroup.Items={bCallReportTable};


            reportGroup.Type='group';
            reportGroup.Name=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolTitle');
            reportGroup.Items={topPanel,searchAndStagePanel,callbackDataGroup};


            dlgstruct.DialogTitle=[DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolTitle'),' : ',obj.m_modelName];
            dlgstruct.CloseCallback='onCallbackTracingReportDialogCloseCallback';
            dlgstruct.CloseArgs={obj,'%dialog',obj.m_modelName};
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.MinMaxButtons=true;
            dlgstruct.Items={reportGroup};

        end

        function onCallbackTracingReportDialogCloseCallback(~,~,model)
            CallbackTracing('Delete',model);
        end

        function setProperties(this,dlgHandle)
            ssComp=dlgHandle.getWidgetInterface('CallbackTracingReportSpreadsheet');

            columns=this.getColumns();
            columnsStruct(1)=struct("name",columns{1},"width",100);
            columnsStruct(2)=struct("name",columns{2},"width",150);
            columnsStruct(3)=struct("name",columns{3},"width",250);
            columnsStruct(5)=struct("name",columns{5},"width",200);
            columnMainStruct=struct("columns",columnsStruct);

            ssComp.setConfig(jsonencode(columnMainStruct));
            this.resetFilterAndButtonStates(dlgHandle);
        end

        function resetFilterAndButtonStates(this,dialogH)
            dialogH.setWidgetValue('FilterIncludeMWLibraryCallbacks',false);
            dialogH.setWidgetValue('FilterBlockCallbacks',true);
            dialogH.setWidgetValue('FilterModelCallbacks',true);
            dialogH.setWidgetValue('FilterPortCallbacks',true);
            dialogH.setWidgetValue('FilterMaskInitCallbacks',true);
            dialogH.setWidgetValue('FilterMaskParameterCallbacks',true);
            if~isempty(this.getStageNames)
                return;
            end
            dialogH.setEnabled('CallbackTracingExportButton',false);
            dialogH.setEnabled('ClearCallbackLogButton',false);
            dialogH.setEnabled('CallbackTracingStageNameList',false);
            dialogH.setEnabled('CallbackTracingReportSpreadsheetFilter',false);
            dialogH.setEnabled('filterGroup',false);
            dialogH.setEnabled('includeGroup',false);
        end

        function columns=getColumns(~)
            sSNoColumn=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolSerialNoColumnName');
            sCallbackTypeColumn=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolCallbackTypeColumnName');
            sObjectNameColumn=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolObjectNameColumnName');
            sCallbackCodeColumn=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolCallbackCodeColumnName');
            sCallbackExecutionTimeColumn=DAStudio.message('Simulink:CallbackTracing:CallbackTracingToolCallbackExecutionTimeColumnName');
            columns={sSNoColumn,sCallbackTypeColumn,sObjectNameColumn,sCallbackCodeColumn,sCallbackExecutionTimeColumn};
        end

        function stages=getStageNames(this)
            stages=this.m_CallReportSpreadsheet.getStageNamesList(this.m_modelName);
            if isempty(stages)
                stages={};
            else
                stages=flip(stages);
            end
        end

        function onModelNameChanged(~,~,evnt,~,~)
            slInternal('resetCallbackTracingReport',evnt.OldName);
            CallbackTracing('Delete',evnt.Source.Name);
        end

        function applyDefaultFilters(this,dialogH)
            stageIdx=dialogH.getWidgetValue('CallbackTracingStageNameList');
            if~isempty(stageIdx)
                this.updateSpreadsheetData(dialogH,this.m_modelName,'CallbackTracingReportSpreadsheet',stageIdx);
                ssComp=dialogH.getWidgetInterface('CallbackTracingReportSpreadsheet');
                ssComp.update(true);
            end
        end

        function updateSpreadsheetData(~,dialogH,model,spreadsheetTag,stageIdx)
            filterMode=struct('IncludeMWLibraryCallbacks',dialogH.getWidgetValue('FilterIncludeMWLibraryCallbacks')...
            ,'BlockCallbacks',dialogH.getWidgetValue('FilterBlockCallbacks')...
            ,'ModelCallbacks',dialogH.getWidgetValue('FilterModelCallbacks')...
            ,'PortCallbacks',dialogH.getWidgetValue('FilterPortCallbacks')...
            ,'MaskInitCallbacks',dialogH.getWidgetValue('FilterMaskInitCallbacks')...
            ,'MaskParameterCallbacks',dialogH.getWidgetValue('FilterMaskParameterCallbacks'));

            spreadsheetObj=dialogH.getUserData(spreadsheetTag);
            spreadsheetObj.updateSpreadSheetChildren(model,stageIdx,filterMode);
            dialogH.apply();
        end

    end

end
