classdef DDGComponentSource<handle

    properties
        component=[];
        value=0;
        viewMode=Simulink.internal.SimulinkProfiler.ViewMode.UI;
        isSpreadsheet=true;
        sheetSource=Simulink.internal.SimulinkProfiler.emptySource;
        hasData=false;
        DDGDialogGetter;
        warning='';
        Url;
        runLabel;

        spreadSheetWidgetName='simulink_profiler_spreadsheet';
    end

    methods
        function this=DDGComponentSource(component)
            this.component=component;
            this.Url=this.component.FlameGraphController.Url;
            this.DDGDialogGetter=Simulink.internal.SimulinkProfiler.DDGDialogGetter;
        end

        function dlgStruct=getDialogSchema(this)


            this.hasData=~strcmpi(this.getCurrentRunLabel(),...
            DAStudio.message('Simulink:Profiler:NoData'));

            if~this.hasData
                this.isSpreadsheet=true;
            end

            filterButton.Type='spreadsheetfilter';
            filterButton.Tag='simulink_profiler_spreadsheet_filter_button';
            filterButton.TargetSpreadsheet='simulink_profiler_spreadsheet';
            filterButton.RowSpan=[1,1];
            filterButton.ColSpan=[8,8];
            filterButton.Clearable=true;
            filterButton.PlaceholderText=DAStudio.message('Simulink:Profiler:SearchBarText');
            filterButton.MinimumSize=[0,0];
            filterButton.Enabled=this.hasData;
            filterButton.Visible=this.isSpreadsheet;
            filterButton.DialogRefresh=false;

            spacerWidget.Type='panel';
            spacerWidget.RowSpan=[1,1];
            spacerWidget.ColSpan=[7,7];



            uiButtonValue=this.viewMode==Simulink.internal.SimulinkProfiler.ViewMode.UI;

            uiViewButton.Type='togglebutton';
            uiViewButton.Tag='simulink_profiler_ui_view_button';
            uiViewButton.RowSpan=[1,1];
            uiViewButton.ColSpan=[3,3];
            uiViewButton.FilePath=fullfile(matlabroot,'toolbox','simulink','simulink','slprofiler',...
            'sltoolstrip','icons','SimulinkModelIcon.png');
            uiViewButton.MatlabMethod='Simulink.internal.SimulinkProfiler.DDGComponentSource.showUIview';
            uiViewButton.MatlabArgs={'%source','%value','%dialog'};
            uiViewButton.Value=uiButtonValue;
            uiViewButton.ToolTip=DAStudio.message('Simulink:Profiler:ModelHierarchy');
            uiViewButton.MaximumSize=[28,24];
            uiViewButton.MinimumSize=[0,0];
            uiViewButton.Graphical=true;
            uiViewButton.Enabled=this.hasData;

            execViewButton.Type='togglebutton';
            execViewButton.Tag='simulink_profiler_exec_view_button';
            execViewButton.RowSpan=[1,1];
            execViewButton.ColSpan=[4,4];
            execViewButton.FilePath=fullfile(matlabroot,'toolbox','simulink','simulink','slprofiler',...
            'sltoolstrip','icons','CallStack.png');
            execViewButton.MatlabMethod='Simulink.internal.SimulinkProfiler.DDGComponentSource.showExecView';
            execViewButton.MatlabArgs={'%source','%value','%dialog'};
            execViewButton.Value=~uiButtonValue;
            execViewButton.ToolTip=DAStudio.message('Simulink:Profiler:ExecutionStack');
            execViewButton.MaximumSize=[28,24];
            execViewButton.MinimumSize=[0,0];
            execViewButton.Graphical=true;
            execViewButton.Enabled=this.hasData;

            deleteRunButton.Type='pushbutton';
            deleteRunButton.Tag='simulink_profiler_toggle_view_button';
            deleteRunButton.ToolTip=DAStudio.message('Simulink:Profiler:DeleteToolTip',...
            this.component.ProfilerAppController.runLabels{this.value+1});
            deleteRunButton.RowSpan=[1,1];
            deleteRunButton.ColSpan=[2,2];
            deleteRunButton.FilePath=fullfile(matlabroot,'toolbox','simulink','simulink','slprofiler',...
            'sltoolstrip','icons','ClearAllPlots_16.png');
            deleteRunButton.MaximumSize=[28,24];
            deleteRunButton.MatlabMethod='Simulink.internal.SimulinkProfiler.DDGComponentSource.deleteRun';
            deleteRunButton.MatlabArgs={'%source','%dialog'};
            deleteRunButton.MinimumSize=[0,0];
            deleteRunButton.Enabled=this.hasData;

            openVizButton.Type='togglebutton';
            openVizButton.Tag='simulink_profiler_open_viz_button';
            openVizButton.ToolTip=DAStudio.message('Simulink:Profiler:OpenFlameGraphTooltip');
            openVizButton.RowSpan=[1,1];
            openVizButton.ColSpan=[5,5];
            openVizButton.FilePath=fullfile(matlabroot,'toolbox','simulink','simulink','slprofiler',...
            'sltoolstrip','icons','plotIconFlamegraph_16.png');
            openVizButton.MaximumSize=[28,24];
            openVizButton.MatlabMethod='Simulink.internal.SimulinkProfiler.DDGComponentSource.toggleFlameGraph';
            openVizButton.MatlabArgs={'%source','%dialog'};
            openVizButton.MinimumSize=[0,0];
            openVizButton.Value=~this.isSpreadsheet;
            openVizButton.Enabled=this.hasData;
            openVizButton.Graphical=true;

            warningIcon.Type='image';
            warningIcon.Tag='simulink_profiler_warning_icon';
            warningIcon.ToolTip=this.warning;
            warningIcon.RowSpan=[1,1];
            warningIcon.ColSpan=[6,6];
            warningIcon.FilePath=fullfile(matlabroot,'toolbox',...
            'shared','dastudio','resources','warning_16.png');
            warningIcon.Visible=~isempty(this.warning);
            warningIcon.MinimumSize=[0,0];

            runSelectorComboBox=struct('Type','combobox','Tag','simulink_profiler_run_selector',...
            'Name','','Graphical',true);
            runSelectorComboBox.Entries=this.component.ProfilerAppController.runLabels;
            runSelectorComboBox.Value=this.value;
            runSelectorComboBox.DialogRefresh=false;
            runSelectorComboBox.SaveState=0;
            runSelectorComboBox.MatlabMethod='Simulink.internal.SimulinkProfiler.DDGComponentSource.selectRun';
            runSelectorComboBox.MatlabArgs={'%source','%value','%dialog','%tag'};
            runSelectorComboBox.RowSpan=[1,1];
            runSelectorComboBox.ColSpan=[1,1];
            runSelectorComboBox.Name=DAStudio.message('Simulink:Profiler:CurrentRun');
            runSelectorComboBox.MinimumSize=[0,0];
            runSelectorComboBox.Enabled=this.hasData;

            if this.isSpreadsheet
                mainWidget.Type='spreadsheet';
                mainWidget.Columns={DAStudio.message('Simulink:Profiler:BlockPath'),...
                DAStudio.message('Simulink:Profiler:TimePlot'),...
                DAStudio.message('Simulink:Profiler:TotalTime'),...
                DAStudio.message('Simulink:Profiler:SelfTime'),...
                DAStudio.message('Simulink:Profiler:NumCalls')};
                mainWidget.Tag=this.spreadSheetWidgetName;
                mainWidget.Source=this.sheetSource;
                mainWidget.Hierarchical=true;
                mainWidget.SortColumn=DAStudio.message('Simulink:Profiler:TotalTime');
            else
                mainWidget.Type='webbrowser';
                mainWidget.Debug=false;
                mainWidget.Url=this.Url;
                mainWidget.Tag='simulink_profiler_flame_graph';
            end

            mainWidget.Name='main_visualization';
            mainWidget.RowSpan=[2,2];
            mainWidget.ColSpan=[1,8];

            if slfeature('slProfilerFlameGraph')>0
                dlgStruct.LayoutGrid=[2,8];
                dlgStruct.ColStretch=[10,1,1,1,1,1,2,5];
                dlgStruct.Items={runSelectorComboBox,deleteRunButton...
                ,uiViewButton,execViewButton,openVizButton,warningIcon...
                ,spacerWidget,filterButton,mainWidget};
                dlgStruct.CloseArgs={this};
                dlgStruct.CloseCallback='Simulink.internal.SimulinkProfiler.DDGComponentSource.onCloseClicked';
            else
                dlgStruct.LayoutGrid=[2,7];
                dlgStruct.ColStretch=[10,1,1,1,1,2,5];
                dlgStruct.Items={runSelectorComboBox,deleteRunButton...
                ,uiViewButton,execViewButton,warningIcon,spacerWidget...
                ,filterButton};
            end

            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;
            dlgStruct.DialogTag='simulink_profiler_full_component';
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};
        end

        function refresh(this)
            fullDialog=this.getToolbarWidget();
            fullDialog.refresh();

            tw=fullDialog.getWidgetInterface(this.spreadSheetWidgetName);
            if~isempty(tw)
                tw.setEmptyListMessage(DAStudio.message('Simulink:Profiler:EmptyListMessage'));
            end

            fullDialog.refresh();
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

        function toggleFlameGraph(source,~)
            source.component.DDGDialogSource.isSpreadsheet=~source.component.DDGDialogSource.isSpreadsheet;
            source.component.DDGDialogSource.Url=source.component.FlameGraphController.reset();
            source.component.DDGDialogSource.refresh();
        end

        function selectRun(source,value,dialog,tag)
            runLabel=dialog.getComboBoxText(tag);
            source.value=value;



            source.component.setSource(runLabel);
        end

        function onCloseClicked(source)
            source.component.hide();
        end

    end

end
