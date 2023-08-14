classdef SpreadSheetToolBar<handle

    properties
        component=[];
        value=0;
        viewMode=Simulink.internal.SimulinkProfiler.ViewMode.UI;
        DDGDialogGetter;
        warning='';
    end

    methods
        function this=SpreadSheetToolBar(DDGDialogGetter)
            if nargin<1
                this.DDGDialogGetter=Simulink.internal.SimulinkProfiler.DDGDialogGetter;
            else

                this.DDGDialogGetter=DDGDialogGetter;
            end
        end

        function dlgStruct=getDialogSchema(this)



            hasData=~strcmpi(this.getCurrentRunLabel(),...
            DAStudio.message('Simulink:Profiler:NoData'));

            filterButton.Type='spreadsheetfilter';
            filterButton.Tag='simulink_profiler_spreadsheet_filter_button';

            filterButton.RowSpan=[1,1];
            filterButton.ColSpan=[8,8];
            filterButton.Clearable=true;
            filterButton.PlaceholderText=DAStudio.message('Simulink:Profiler:SearchBarText');
            filterButton.MinimumSize=[0,0];
            filterButton.Enabled=hasData;

            spacerWidget.Type='panel';
            spacerWidget.RowSpan=[1,1];
            spacerWidget.ColSpan=[7,7];



            uiButtonValue=this.viewMode==Simulink.internal.SimulinkProfiler.ViewMode.UI;

            uiViewButton.Type='togglebutton';
            uiViewButton.Tag='simulink_profiler_ui_view_button';
            uiViewButton.RowSpan=[1,1];
            uiViewButton.ColSpan=[3,3];
            uiViewButton.FilePath=fullfile(matlabroot,'toolbox','simulink','simulink','slprofiler','sltoolstrip','icons','SimulinkModelIcon.png');
            uiViewButton.MatlabMethod='Simulink.internal.SimulinkProfiler.SpreadSheetToolBar.showUIview';
            uiViewButton.MatlabArgs={'%source','%value','%dialog'};
            uiViewButton.Value=uiButtonValue;
            uiViewButton.ToolTip=DAStudio.message('Simulink:Profiler:ModelHierarchy');
            uiViewButton.MaximumSize=[28,24];
            uiViewButton.MinimumSize=[0,0];
            uiViewButton.Graphical=true;
            uiViewButton.Enabled=hasData;

            execViewButton.Type='togglebutton';
            execViewButton.Tag='simulink_profiler_exec_view_button';
            execViewButton.RowSpan=[1,1];
            execViewButton.ColSpan=[4,4];
            execViewButton.FilePath=fullfile(matlabroot,'toolbox','simulink','simulink','slprofiler','sltoolstrip','icons','CallStack.png');
            execViewButton.MatlabMethod='Simulink.internal.SimulinkProfiler.SpreadSheetToolBar.showExecView';
            execViewButton.MatlabArgs={'%source','%value','%dialog'};
            execViewButton.Value=~uiButtonValue;
            execViewButton.ToolTip=DAStudio.message('Simulink:Profiler:ExecutionStack');
            execViewButton.MaximumSize=[28,24];
            execViewButton.MinimumSize=[0,0];
            execViewButton.Graphical=true;
            execViewButton.Enabled=hasData;

            deleteRunButton.Type='pushbutton';
            deleteRunButton.Tag='simulink_profiler_toggle_view_button';
            deleteRunButton.ToolTip=DAStudio.message('Simulink:Profiler:DeleteToolTip',this.component.ProfilerAppController.runLabels{this.value+1});
            deleteRunButton.RowSpan=[1,1];
            deleteRunButton.ColSpan=[2,2];
            deleteRunButton.FilePath=fullfile(matlabroot,'toolbox','simulink','simulink','slprofiler','sltoolstrip','icons','ClearAllPlots_16.png');
            deleteRunButton.MaximumSize=[28,24];
            deleteRunButton.MatlabMethod='Simulink.internal.SimulinkProfiler.SpreadSheetToolBar.deleteRun';
            deleteRunButton.MatlabArgs={'%source','%dialog'};
            deleteRunButton.MinimumSize=[0,0];
            deleteRunButton.Enabled=hasData;

            warningIcon.Type='image';
            warningIcon.Tag='simulink_profiler_warning_icon';
            warningIcon.ToolTip=this.warning;
            warningIcon.RowSpan=[1,1];
            warningIcon.ColSpan=[6,6];
            warningIcon.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','warning_16.png');
            warningIcon.Visible=~isempty(this.warning);
            warningIcon.MinimumSize=[0,0];

            runSelectorComboBox=struct('Type','combobox','Tag','simulink_profiler_run_selector','Name','','Graphical',true);
            runSelectorComboBox.Entries=this.component.ProfilerAppController.runLabels;
            runSelectorComboBox.Value=this.value;
            runSelectorComboBox.DialogRefresh=0;
            runSelectorComboBox.SaveState=0;
            runSelectorComboBox.MatlabMethod='Simulink.internal.SimulinkProfiler.SpreadSheetToolBar.selectRun';
            runSelectorComboBox.MatlabArgs={'%source','%value','%dialog','%tag'};
            runSelectorComboBox.RowSpan=[1,1];
            runSelectorComboBox.ColSpan=[1,1];
            runSelectorComboBox.Name=DAStudio.message('Simulink:Profiler:CurrentRun');
            runSelectorComboBox.MinimumSize=[0,0];
            runSelectorComboBox.Enabled=hasData;

            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;


            if slfeature('slProfilerFlameGraph')>0
                dlgStruct.LayoutGrid=[1,8];
                dlgStruct.ColStretch=[10,1,1,1,1,1,2,5];
                dlgStruct.Items={runSelectorComboBox,deleteRunButton,uiViewButton,execViewButton,openVizButton,warningIcon,spacerWidget,filterButton};
            else
                dlgStruct.LayoutGrid=[1,7];
                dlgStruct.ColStretch=[10,1,1,1,1,2,5];
                dlgStruct.Items={runSelectorComboBox,deleteRunButton,uiViewButton,execViewButton,warningIcon,spacerWidget,filterButton};
            end

            dlgStruct.DialogTag='simulink_profiler_spreadsheet_toolbar';
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};
        end

        function refresh(this)
            toolbarWidget=this.getToolbarWidget();
            toolbarWidget.refresh();
        end

        function toolbarWidget=getToolbarWidget(this)
            toolbarWidget=this.DDGDialogGetter.get(this);
        end

        function runLabel=getCurrentRunLabel(this)
            runLabel=this.component.ProfilerAppController.runLabels(this.value+1);
        end

        function setCurrentRunLabel(this,runLabel)
            if strcmp(runLabel,DAStudio.message('Simulink:Profiler:NoData'))
                idx=1;
                theWarning='';
            else
                idx=find(strcmp(runLabel,this.component.ProfilerAppController.runLabels));
                theWarning=this.component.ProfilerAppController.warnings(runLabel);
            end
            assert(numel(idx)==1);
            this.value=idx-1;
            this.warning=theWarning;
            this.refresh();
        end

    end

    methods(Static)












        function showUIview(source,value,dialog)
            if value
                source.viewMode=Simulink.internal.SimulinkProfiler.ViewMode.UI;
            else
                source.viewMode=Simulink.internal.SimulinkProfiler.ViewMode.EXEC;
            end
            runLabel=dialog.getComboBoxText('simulink_profiler_run_selector');
            source.component.setSource(runLabel,source.viewMode);


            dialog.setWidgetValue('simulink_profiler_exec_view_button',~value);
        end

        function showExecView(source,value,dialog)
            if value
                source.viewMode=Simulink.internal.SimulinkProfiler.ViewMode.EXEC;
            else
                source.viewMode=Simulink.internal.SimulinkProfiler.ViewMode.UI;
            end
            runLabel=dialog.getComboBoxText('simulink_profiler_run_selector');
            source.component.setSource(runLabel,source.viewMode);


            dialog.setWidgetValue('simulink_profiler_ui_view_button',~value);
        end

        function deleteRun(source,dialog)
            runLabelToBeDeleted=dialog.getComboBoxText('simulink_profiler_run_selector');

            if strcmp(runLabelToBeDeleted,DAStudio.message('Simulink:Profiler:NoData'))
                return;
            end


            source.component.ProfilerAppController.deleteRun(runLabelToBeDeleted);
        end

        function openWindow(source,~)
            source.component.vizWindow.show();
        end

        function selectRun(source,value,dialog,tag)
            runLabel=dialog.getComboBoxText(tag);
            source.value=value;



            source.component.setSource(runLabel);
        end

    end

end