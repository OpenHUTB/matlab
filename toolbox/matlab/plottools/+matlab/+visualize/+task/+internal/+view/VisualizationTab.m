classdef(Hidden)VisualizationTab<handle






    properties(Access={?matlab.internal.visualizelivetask.utils.hVisualizeLiveTask,?hVisualizeTaskBase})

        TabGridLayout matlab.ui.container.GridLayout


        MainAccordion matlab.ui.container.internal.Accordion
        VisualizationPanel matlab.ui.container.internal.AccordionPanel
        DataPanel matlab.ui.container.internal.AccordionPanel
        OptionalParameterPanel matlab.ui.container.internal.AccordionPanel



        VisualizationView matlab.visualize.task.internal.view.VisualizationPanel
        DataView matlab.visualize.task.internal.view.DataPanel
        OptionalParamView matlab.visualize.task.internal.view.OptionalParametersPanel
    end

    properties(Access=?hVisualizeTaskBase)

        Model matlab.visualize.task.internal.model.VisualizeTaskModel
State
        OverlayAdded(1,1)logical
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
ParentTab

        TabStateChangedListener event.listener
        VizChangedListener event.listener
        DataChangedListener event.listener
        ConfigurationChangedListener event.listener


        MetadataUpdatedListener event.listener
    end

    events

ViewChanged
    end

    methods(Hidden)
        function obj=VisualizationTab(tabToParent,overlayAdded)
            obj.ParentTab=tabToParent;

            obj.Model=matlab.visualize.task.internal.model.VisualizeTaskModel();
            if nargin>1
                obj.OverlayAdded=overlayAdded;
            end
            obj.Model.initModel(obj.OverlayAdded);


            obj.createComponents();


            obj.createSubViews();


            obj.VisualizationView.updateView(obj.Model);



            obj.addViewListeners();
        end

        function updateOverlayAdded(obj,overlayAdded)
            obj.OverlayAdded=overlayAdded;
            obj.Model.OverlayAdded=overlayAdded;
            if obj.VisualizationView.hasChartShowing
                obj.VisualizationView.updateState(obj.Model,obj.Model.findMatchingVizForData());
            else
                obj.VisualizationView.updateEnabledCharts(obj.Model,obj.Model.findMatchingVizForData());
            end
        end

        function createComponents(obj)

            obj.TabGridLayout=uigridlayout(obj.ParentTab);
            obj.TabGridLayout.ColumnWidth={'1x'};
            obj.TabGridLayout.RowHeight={'fit'};


            obj.MainAccordion=matlab.ui.container.internal.Accordion('Parent',obj.TabGridLayout);
            obj.VisualizationPanel=matlab.ui.container.internal.AccordionPanel('Parent',obj.MainAccordion,...
            'Title',getString(message('MATLAB:graphics:visualizedatatask:SelectVizLabel')));

            obj.DataPanel=matlab.ui.container.internal.AccordionPanel('Parent',obj.MainAccordion,...
            'Title',getString(message('MATLAB:graphics:visualizedatatask:SelectDataPanelLabel')));

            obj.OptionalParameterPanel=matlab.ui.container.internal.AccordionPanel('Parent',obj.MainAccordion,...
            'Title',getString(message('MATLAB:graphics:visualizedatatask:SelectOptionalPanelLabel')),...
            'Collapsed',true);
        end

        function initialize(obj,userKeyword)
            obj.VisualizationView.preSelectVisualization(userKeyword);
        end

        function preSelectVisualization(obj,inputsToPreselect)

            if~isempty(inputsToPreselect.ChartName)
                obj.VisualizationView.selectVisualization(inputsToPreselect.ChartName);
                obj.updateTabState();
                obj.Model.updateModelForVizUpdate();
                obj.DataView.updateView(obj.Model);
                obj.OptionalParamView.updateView(obj.Model);
                obj.VisualizationView.updateState(obj.Model,obj.Model.findMatchingVizForData());
            end


            dataRowSelection=inputsToPreselect.XDataRow;
            dataModel=obj.Model.DataModel;
            dataModel.SelectedConfiguration=inputsToPreselect.Configuration;
            if~isempty(inputsToPreselect.Configuration)
                obj.Model.updateChannelsForConfiguration();
            end
            if~isempty(dataRowSelection)
                if~isempty(dataModel.MappedDataRows)
                    mappedFirstRow=dataModel.MappedDataRows(1);
                    mappedFirstRow.WorkspaceVarName=dataRowSelection.WorkspaceVarName;
                    mappedFirstRow.VariableName=dataRowSelection.VariableName;
                    mappedFirstRow.IsTabular=dataRowSelection.IsTabular;

                    dataRow=matlab.visualize.task.internal.model.DataProperties();
                    dataRow.WorkspaceVarName=dataRowSelection.WorkspaceVarName;
                    dataRow.VariableName=dataRowSelection.VariableName;
                    dataRow.IsTabular=dataRowSelection.IsTabular;
                    dataModel.DataRows=dataRow;
                elseif~isempty(dataModel.DataRows)
                    dataRow=dataModel.DataRows(1);
                    dataRow.WorkspaceVarName=dataRowSelection.WorkspaceVarName;
                    dataRow.VariableName=dataRowSelection.VariableName;
                    dataRow.IsTabular=dataRowSelection.IsTabular;
                end


                chartModel=obj.Model.ChartModel;
                chartIndex=chartModel.SelectionIdx;
                if chartIndex>0
                    chartMetaData=chartModel.ChartMetaData{chartIndex};
                    channels=obj.getChannelsFromConfiguration(chartMetaData);
                end
                hasMappings=any(arrayfun(@(x)~isempty(x.MappedRow),channels));





                if hasMappings&&~isempty(dataRow)
                    channel=channels(1);
                    if~isempty(channel.MappedRow)&&...
                        ~isequal(channel.DataMapped,dataRow.VariableName)
                        channel.MappedRow.WorkspaceVarName=dataRow.WorkspaceVarName;
                        channel.MappedRow.VariableName=dataRow.VariableName;
                        channel.MappedRow.IsTabular=dataRow.IsTabular;
                        channel.DataMapped=dataRow.VariableName;
                    end
                end
            end
            obj.DataView.updateView(obj.Model);


        end

        function inputsToPreselect=getInputsForPreSelection(obj)
            inputsToPreselect=struct('ChartName','','XDataRow','','Configuration','');
            chartModel=obj.Model.ChartModel;
            if chartModel.SelectionIdx>-1
                inputsToPreselect.ChartName=chartModel.ChartMetaData{chartModel.SelectionIdx}.Name;
            end
            dataModel=obj.Model.DataModel;
            inputsToPreselect.Configuration=dataModel.SelectedConfiguration;
            dataRow=dataModel.MappedDataRows;
            if isempty(dataRow)
                dataRow=dataModel.DataRows;
            end
            if~isempty(dataRow)
                mappedChannel=dataRow(1).MappedChannel;
                if~isempty(mappedChannel)&&...
                    (strcmpi(mappedChannel.Name,'X')||strcmpi(mappedChannel.Description,'X'))
                    inputsToPreselect.XDataRow=dataRow(1);
                end
            end
        end

        function createSubViews(obj)

            obj.VisualizationView=matlab.visualize.task.internal.view.VisualizationPanel(...
            obj.VisualizationPanel,obj.Model);

            obj.DataView=matlab.visualize.task.internal.view.DataPanel(...
            obj.DataPanel,obj.Model);




            obj.OptionalParamView=matlab.visualize.task.internal.view.OptionalParametersPanel(...
            obj.OptionalParameterPanel,obj.Model);
        end



        function addViewListeners(obj)

            fun=@(x)addlistener(x,'ValueChangedEvent',@(e,d)obj.tabStateChanged());
            obj.TabStateChangedListener=arrayfun(fun,[obj.VisualizationView,...
            obj.DataView,obj.OptionalParamView]);





            hInstance=matlab.visualize.task.internal.utils.FunctionMetaData.getInstance();
            obj.MetadataUpdatedListener=event.listener(hInstance,'FunctionMetaDataUpdated',@(e,d)obj.functionMetaDataUpdated);



            obj.VizChangedListener=addlistener(obj.VisualizationView,'VisualizationSelectionChanged',@(e,d)obj.visualizationChanged());


            obj.DataChangedListener=addlistener(obj.DataView,'DataSelectionChanged',@(e,d)obj.dataChanged());



            obj.ConfigurationChangedListener=addlistener(obj.DataView,'ConfigurationChanged',@(e,d)obj.configurationChanged());
        end

        function functionMetaDataUpdated(obj)
            delete(obj.MetadataUpdatedListener);
            obj.initializeModelAndView();
            if~isempty(obj.State)
                obj.setState(obj.State);
            end
        end


        function tabStateChanged(obj)
            notify(obj,'ViewChanged');
        end


        function visualizationChanged(obj)
            obj.updateTabState();




            obj.Model.updateModelForVizUpdate();


            obj.DataView.updateView(obj.Model);
            obj.OptionalParamView.updateView(obj.Model);


            obj.tabStateChanged();
        end


        function dataChanged(obj)



            obj.tabStateChanged();
            drawnow nocallbacks;
            allMatchingCharts=obj.Model.findMatchingVizForData();
            obj.VisualizationView.updateState(obj.Model,allMatchingCharts);
        end


        function configurationChanged(obj)

            obj.Model.updateChannelsForConfiguration();


            obj.DataView.updateSubView(obj.Model);


            obj.tabStateChanged();
        end


        function initializeModelAndView(obj)
            obj.Model.initModel(obj.OverlayAdded);
            obj.VisualizationView.updateView(obj.Model);
        end




        function channels=getChannelsFromConfiguration(obj,chartMetaData)
            channelConfigMap=chartMetaData.ChannelConfigurationMap;
            if~isempty(channelConfigMap)
                selectedConfig=obj.DataView.getSelectedConfiguration();
                channels=channelConfigMap(selectedConfig).Channels;
            else
                channels=chartMetaData.Channels;
            end
        end

        function updateTabState(obj)
            chartModel=obj.Model.ChartModel;
            chartIndex=chartModel.SelectionIdx;
            if chartIndex>0
                chartData=chartModel.ChartMetaData{chartIndex};
                obj.ParentTab.Title=chartData.Name;
            else
                obj.ParentTab.Title=getString(message('MATLAB:graphics:visualizedatatask:CreateLabel'));
            end
        end



        function updateView(obj)

            obj.VisualizationView.updateView(obj.Model);
            obj.DataView.updateView(obj.Model);
            obj.OptionalParamView.updateView(obj.Model);
            obj.updateTabState();
        end


        function delete(obj)
            delete([obj.TabStateChangedListener,...
            obj.VizChangedListener,...
            obj.DataChangedListener,...
            obj.MetadataUpdatedListener,...
            obj.ConfigurationChangedListener]);
        end
    end

    methods(Hidden)

        function[hasViz,overlaySupported]=hasVisualizationCreated(obj)
            hasViz=false;
            overlaySupported=false;
            chartModel=obj.Model.ChartModel;
            chartIndex=chartModel.SelectionIdx;
            if chartIndex>0
                chartMetaData=chartModel.ChartMetaData{chartIndex};
                overlaySupported=chartMetaData.SupportsOverlay;
                channels=obj.getChannelsFromConfiguration(chartMetaData);

                if all(arrayfun(@(x)~isempty(x.DataMapped)&&...
                    (x.IsRequired&&~strcmpi(x.DataMapped,'select variable'))||~x.IsRequired,channels))
                    hasViz=true;
                end
            end
        end



        function summary=getDefaultSummaryLine(obj)
            chartModel=obj.Model.ChartModel;
            chartIndex=chartModel.SelectionIdx;
            summary=getString(message('MATLAB:graphics:visualizedatatask:Tool_VisualizeDataTask_Description'));
            if chartIndex>0
                summary=getString(message('MATLAB:graphics:visualizedatatask:ChartInPurposeLine',...
                chartModel.ChartMetaData{chartIndex}.Name));
            end
        end










        function[code,outputs]=generateScript(obj)
            code='';
            outputs={};
            chartModel=obj.Model.ChartModel;
            chartIndex=chartModel.SelectionIdx;
            if chartIndex>0
                chartMetaData=chartModel.ChartMetaData{chartIndex};
                channels=obj.getChannelsFromConfiguration(chartMetaData);

                if~isempty(chartMetaData.Outputs)&&...
                    all(arrayfun(@(x)~isempty(x.DataMapped)&&...
                    (x.IsRequired&&~strcmpi(x.DataMapped,'select variable'))||~x.IsRequired,channels))
                    numOutputs=numel(chartMetaData.Outputs);
                    if numOutputs==1
                        outputs={chartMetaData.Outputs.name};
                    else
                        outputs={};
                        for i=1:numOutputs
                            outputs=[outputs,chartMetaData.Outputs(i).name];%#ok<AGROW>
                        end
                    end
                end
            end
        end



        function[code,summaryLine,outputVar]=generateVisualizationScript(obj,doGenerateLabels)
            code='';
            summaryLine='';
            outputVar={};

            chartModel=obj.Model.ChartModel;
            chartIndex=chartModel.SelectionIdx;
            dataRows=obj.Model.DataModel.getAllDataRows();


            if chartIndex>0&&~isempty(dataRows)
                chartMetaData=chartModel.ChartMetaData{chartIndex};
                chartName=chartMetaData.Name;
                if~isempty(chartMetaData.Outputs)
                    outputVar=chartMetaData.Outputs;
                end


                optionalParameters=obj.Model.OptionalParamModel.getAllOptionsRows();
                channels=obj.getChannelsFromConfiguration(chartMetaData);
                if~isempty(chartMetaData.CodeGenFunction)
                    generatedCode=hgfeval({chartMetaData.CodeGenFunction},...
                    chartName,chartMetaData.Outputs,channels,optionalParameters,doGenerateLabels);
                    vizCode=generatedCode{1};
                    summaryLine=generatedCode{2};
                else
                    [vizCode,summaryLine]=matlab.visualize.task.internal.codegen.defaults.generateCode(chartMetaData,...
                    channels,optionalParameters,doGenerateLabels);
                end

                if~isempty(vizCode)
                    code=[code,vizCode];
                end
            end
        end
















        function state=getState(obj)


            if~matlab.visualize.task.internal.utils.FunctionMetaData.hasMetadataLoaded()
                state=obj.State;
                return;
            end
            chartModel=obj.Model.ChartModel;
            selChartIdx=chartModel.SelectionIdx;
            chartData=[];
            if selChartIdx>0
                chartData=chartModel.ChartMetaData{selChartIdx};
            end
            state=struct('SelectedChartData',chartData,...
            'CurrentCategory',chartModel.CurrentCategory,...
            'CurrentSearchTerm',chartModel.CurrentSearchTerm,...
            'EnabledCharts',{chartModel.EnabledCharts},...
            'DataModel',obj.Model.DataModel,...
            'PanelState',{get(obj.MainAccordion.Children,'Collapsed')});
        end





        function setState(obj,state)



            if~isempty(state)&&isstruct(state)&&...
                ~isempty(fieldnames(state))
                obj.State=state;
                if isfield(state,'SelectedChartData')
                    obj.Model.setState(state);

                    for i=1:numel(obj.MainAccordion.Children)
                        if numel(state.PanelState)<i
                            break;
                        end
                        set(obj.MainAccordion.Children(i),'Collapsed',state.PanelState(i))
                    end
                    obj.updateView();
                end
                if isfield(state,'code')
                    userKeyword=state.code;
                    obj.VisualizationView.preSelectVisualization(userKeyword);
                end
            end
        end



        function reset(app)
            set(app.VisualizationPanel,'Collapsed',false);
            set(app.DataPanel,'Collapsed',false);
            set(app.OptionalParameterPanel,'Collapsed',true);
            app.Model.restoreDefaultModel();
            allMatchingCharts=app.Model.findMatchingVizForData();
            app.VisualizationView.updateState(app.Model,allMatchingCharts);
            app.updateView();
        end
    end
end