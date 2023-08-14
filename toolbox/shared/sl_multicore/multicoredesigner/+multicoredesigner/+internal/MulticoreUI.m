classdef MulticoreUI<handle




    properties
        ModelH;
        CostEditor;
        TaskEditor;
        TaskLegend;
        SpeedupPanel;
        TaskHighlighter;
        CriticalPathHighlighter;
        TaskView;
        MappingData;
        SimMappingData;
        RTWMappingData;
        MCContext;
        MCMode;
    end

    methods
        function obj=MulticoreUI(modelH)
            obj.ModelH=modelH;
            obj.TaskView=true;

            obj.MCContext=multicoredesigner.internal.getAppContext(obj.ModelH);
            assert(~isempty(obj.MCContext));
            obj.MCMode=obj.MCContext.Mode;


            multicoredesigner.internal.MappingData.updateDataModelHierarchy(modelH);


            obj.RTWMappingData=multicoredesigner.internal.MappingData(modelH,slmulticore.CostMethod.User);
            addlistener(obj.RTWMappingData,'TaskRemovedEvent',@obj.handleTaskRemovedEvent);
            update(obj.RTWMappingData);
            obj.SimMappingData=multicoredesigner.internal.MappingData(modelH,slmulticore.CostMethod.Simulation);
            update(obj.SimMappingData);


            if strcmpi(obj.MCMode,'SimulationProfiling')
                obj.MappingData=obj.SimMappingData;
            else
                obj.MappingData=obj.RTWMappingData;
            end


            obj.TaskHighlighter=multicoredesigner.internal.TaskHighlighter(obj);
            addlistener(obj.TaskHighlighter,'HighlightingOnEvent',@obj.handleHighlightingEvent);
            addlistener(obj.TaskHighlighter,'HighlightingOffEvent',@obj.handleHighlightingEvent);

            obj.CriticalPathHighlighter=multicoredesigner.internal.CriticalPathHighlighter(obj);
            addlistener(obj.CriticalPathHighlighter,'HighlightingOnEvent',@obj.handleHighlightingEvent);
            addlistener(obj.CriticalPathHighlighter,'HighlightingOffEvent',@obj.handleHighlightingEvent);


            obj.CostEditor=createCostEditor(obj);
            obj.TaskEditor=createTaskEditor(obj);
            obj.SpeedupPanel=createSpeedupPanel(obj);
            obj.TaskLegend=createTaskLegend(obj);
        end

        function delete(obj)

            if is_simulink_handle(obj.ModelH)&&...
                ~slInternal('isBDClosing',obj.ModelH)

                if~isempty(obj.CostEditor)&&isvalid(obj.CostEditor)
                    close(obj.CostEditor);
                    delete(obj.CostEditor);
                end
                if~isempty(obj.TaskEditor)&&isvalid(obj.TaskEditor)
                    close(obj.TaskEditor);
                    delete(obj.TaskEditor);
                end
                if~isempty(obj.TaskLegend)&&isvalid(obj.TaskLegend)
                    close(obj.TaskLegend);
                    delete(obj.TaskEditor);
                end
                if~isempty(obj.SpeedupPanel)&&isvalid(obj.SpeedupPanel)
                    close(obj.SpeedupPanel);
                    delete(obj.TaskEditor);
                end

                if~isempty(obj.RTWMappingData)&&isvalid(obj.RTWMappingData)
                    delete(obj.RTWMappingData);
                end

                if~isempty(obj.SimMappingData)&&isvalid(obj.SimMappingData)
                    delete(obj.SimMappingData);
                end

                if~isempty(obj.TaskHighlighter)&&isvalid(obj.TaskHighlighter)
                    removeAllHighlighting(obj.TaskHighlighter);
                    delete(obj.TaskHighlighter);
                end

                if~isempty(obj.CriticalPathHighlighter)&&isvalid(obj.CriticalPathHighlighter)
                    removeAllHighlighting(obj.CriticalPathHighlighter);
                    delete(obj.CriticalPathHighlighter);
                end

                dataflowUI=get_param(obj.ModelH,'DataflowUI');
                if~isempty(dataflowUI)
                    if dataflowUI.isLatencyPortAnnotationsVisible
                        dataflowUI.hideLatencyPortAnnotations();
                    end
                end
            end
        end

        function setMode(obj,mode)
            if~strcmpi(obj.MCMode,mode)
                obj.MCMode=mode;

                if strcmpi(obj.MCMode,'SimulationProfiling')
                    obj.MappingData=obj.SimMappingData;
                else
                    obj.MappingData=obj.RTWMappingData;
                end
            end
        end

        function mappingData=getMappingData(obj)
            mappingData=obj.MappingData;
        end

        function th=getTaskHighlighter(obj)
            th=obj.TaskHighlighter;
        end

        function ch=getCriticalPathHighlighter(obj)
            ch=obj.CriticalPathHighlighter;
        end

        function h=getTaskLegend(obj)
            h=obj.TaskLegend;
        end

        function h=getCostEditor(obj)
            h=obj.CostEditor;
        end

        function h=getTaskEditor(obj)
            h=obj.TaskEditor;
        end

        function h=getSpeedupPanel(obj)
            h=obj.SpeedupPanel;
        end

        function updateAnalysisResults(obj)

            if isvalid(obj.MappingData)
                update(obj.MappingData);
            end
            handleMappingDataUpdateEvent(obj);
        end

        function h=getModelHandle(obj)
            h=obj.ModelH;
        end

        function highlightAllTasks(obj)
            if isvalid(obj.TaskHighlighter)
                highlightAll(obj.TaskHighlighter);
            end
        end

        function highlightAllCriticalPaths(obj)
            if isvalid(obj.CriticalPathHighlighter)
                highlightAll(obj.CriticalPathHighlighter);
            end
        end

        function removeAllHighlighting(obj)
            removeTaskHighlighting(obj);
            removeCriticalPathHighlighting(obj);
        end

        function removeTaskHighlighting(obj)
            if isvalid(obj.TaskHighlighter)
                removeAllHighlighting(obj.TaskHighlighter);
            end

            if~isempty(obj.TaskLegend)&&isvalid(obj.TaskLegend)
                update(obj.TaskLegend);
                expand(obj.TaskLegend);
            end
        end

        function removeCriticalPathHighlighting(obj)
            if isvalid(obj.CriticalPathHighlighter)
                removeAllHighlighting(obj.CriticalPathHighlighter);
            end
        end

        function changeView(obj,val)
            obj.TaskView=val;
            if~isempty(obj.TaskEditor)&&isvalid(obj.TaskEditor)
                updateColumns(obj.TaskEditor);
                expand(obj.TaskEditor);
            end
        end
        function importCostFromMATFile(obj,filePath)
            m=load(filePath);
            t=m.costData;


            set_param(obj.ModelH,'SimulationCommand','update');

            mfModel=get_param(obj.ModelH,'MulticoreDataModel');
            mc=slmulticore.MulticoreConfig.getMulticoreConfig(mfModel);
            blocks=mc.blocks.toArray;

            for b=blocks
                b.allowUserCost=1;
                b.userCost=table2array(t(strcmp(t.blockPath,b.path),2));
            end


            updateAnalysisResults(obj);
            costEditor=getCostEditor(obj);
            show(costEditor);
            expand(costEditor);
            obj.MCContext.refreshCostValidStatus();
        end
    end
    methods(Access=private)

        function costEditor=createCostEditor(obj)
            costEditor=multicoredesigner.internal.MulticoreSpreadsheet(obj,'MulticoreCostEditor');
            addlistener(costEditor,'SpreadSheetCloseAction',@obj.handleCloseEvent);
            costEditor.setPlaceholderText(getString(message('dataflow:Spreadsheet:SubsystemNeedsCost')));
            dataSource=multicoredesigner.internal.CostEditorDataSource(obj,costEditor);
            costEditor.setDataSource(dataSource);
            costEditor.setTitle(getString(message('dataflow:Spreadsheet:CostEditorTitle')));
            costEditor.Component.setPreferredSize(450,200);
            costEditor.placeComponent('Bottom','stacked');
            costEditor.hide();
        end

        function taskEditor=createTaskEditor(obj)
            taskEditor=multicoredesigner.internal.MulticoreSpreadsheet(obj,'MulticoreTaskEditor');
            addlistener(taskEditor,'SpreadSheetCloseAction',@obj.handleCloseEvent);
            taskEditor.setPlaceholderText(getString(message('dataflow:Spreadsheet:SubsystemNeedsAnalysis')));
            dataSource=multicoredesigner.internal.TaskEditorDataSource(obj,taskEditor);
            taskEditorMenu=multicoredesigner.internal.TaskEditorMenu(obj);
            taskEditor.setDataSource(dataSource,taskEditorMenu);
            taskEditor.setTitle(getString(message('dataflow:Spreadsheet:TaskEditorTitle')));
            taskEditor.placeComponent('Bottom','tabbed');
            taskEditor.hide();
        end

        function taskLegend=createTaskLegend(obj)

            taskLegend=multicoredesigner.internal.MulticoreSpreadsheet(obj,'MulticoreTaskLegend');
            addlistener(taskLegend,'SpreadSheetCloseAction',@obj.handleCloseEvent);
            taskLegend.setPlaceholderText(getString(message('dataflow:Spreadsheet:SubsystemNeedsAnalysis')));
            dataSource=multicoredesigner.internal.TaskLegendDataSource(obj,taskLegend);
            taskLegend.setDataSource(dataSource);
            taskLegend.setTitle(getString(message('dataflow:Spreadsheet:TaskLegendTitle')));
            taskLegend.Component.setPreferredSize(300,200);
            taskLegend.placeComponent('Right','stacked');
            taskLegend.hide();
        end

        function speedupPanel=createSpeedupPanel(obj)
            dataSource=multicoredesigner.internal.MulticoreSpeedupDataSource(obj);
            speedupPanel=multicoredesigner.internal.MulticoreDDGComponent(obj,'MulticoreSpeedupPanel',dataSource);
            addlistener(speedupPanel,'DDGComponentCloseAction',@obj.handleCloseEvent);
            speedupPanel.setTitle(getString(message('dataflow:Spreadsheet:AnalysisReportPanelTitle')));
            speedupPanel.Component.setPreferredSize(300,500);
            speedupPanel.placeComponent('Right','tabbed');
            speedupPanel.hide();
        end

        function handleCloseEvent(obj,src,~)
            if is_simulink_handle(obj.ModelH)&&...
                ~slInternal('isBDClosing',obj.ModelH)
                if isa(src,'multicoredesigner.internal.MulticoreSpreadsheet')
                    if contains(src.ComponentName,'MulticoreTaskLegend')
                        removeAllHighlighting(obj);
                    end
                    if contains(src.ComponentName,{'MulticoreCostEditor','MulticoreTaskEditor','MulticoreSpeedupPanel'})
                        handleCloseAction(obj);
                    end
                elseif isa(src,'multicoredesigner.internal.MulticoreDDGComponent')
                    if contains(src.ComponentName,'MulticoreSpeedupPanel')
                        handleCloseAction(obj);
                    end
                end

            end
        end

        function handleCloseAction(obj)
            context=multicoredesigner.internal.getAppContext(obj.ModelH);
            if~isempty(context)
                context.notifyResultGalley();
            end
        end

        function handleTaskRemovedEvent(obj,~,~)
            if~isempty(obj.TaskEditor)&&isvalid(obj.TaskEditor)
                update(obj.TaskEditor);
                expand(obj.TaskLegend);
            end

            if~isempty(obj.TaskLegend)&&isvalid(obj.TaskLegend)
                update(obj.TaskLegend);
                expand(obj.TaskLegend);
            end
        end

        function handleMappingDataUpdateEvent(obj,~,~)

            if~isempty(obj.CostEditor)&&isvalid(obj.CostEditor)
                updateColumns(obj.CostEditor);
                update(obj.CostEditor);
                expand(obj.CostEditor);
            end

            if~isempty(obj.TaskEditor)&&isvalid(obj.TaskEditor)
                update(obj.TaskEditor);
                expand(obj.TaskLegend);
            end

            if~isempty(obj.CriticalPathHighlighter)&&isvalid(obj.CriticalPathHighlighter)
                removeAllHighlighting(obj.CriticalPathHighlighter);
            end

            if~isempty(obj.TaskHighlighter)&&isvalid(obj.TaskHighlighter)
                removeAllHighlighting(obj.TaskHighlighter);
            end

            if~isempty(obj.TaskLegend)&&isvalid(obj.TaskLegend)
                update(obj.TaskLegend);
                expand(obj.TaskLegend);
            end

            if~isempty(obj.SpeedupPanel)&&isvalid(obj.SpeedupPanel)
                update(obj.SpeedupPanel);
            end
        end

        function handleHighlightingEvent(obj,src,evt)
            context=multicoredesigner.internal.getAppContext(obj.ModelH);
            if~isempty(context)
                context.notifyHighlightingChange(src,evt);
            end
        end
    end
end


