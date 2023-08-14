classdef(Hidden)VisualizationMainView<handle





    properties(Access={?matlab.internal.visualizelivetask.utils.hVisualizeLiveTask,?hVisualizeTaskBase})

        ParentGridLayout matlab.ui.container.GridLayout


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
    end

    properties(Hidden,SetAccess=private,GetAccess=public)

        ViewChangedListener event.listener
        VizChangedListener event.listener
        DataChangedListener event.listener
        ConfigurationChangedListener event.listener


        MetadataUpdatedListener event.listener
    end

    events

ViewChanged
    end

    methods(Hidden)
        function obj=VisualizationMainView(gridLayout)
            obj.ParentGridLayout=gridLayout;


            obj.Model=matlab.visualize.task.internal.model.VisualizeTaskModel();


            obj.createComponents();


            obj.createSubViews();



            obj.addViewListeners();


            obj.initializeModelAndView();
        end

        function createComponents(obj)

            obj.MainAccordion=matlab.ui.container.internal.Accordion('Parent',obj.ParentGridLayout);
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



        function updateView(obj)

            obj.VisualizationView.updateView(obj.Model);
            obj.DataView.updateView(obj.Model);
            obj.OptionalParamView.updateView(obj.Model);
        end

        function createSubViews(obj)

            obj.VisualizationView=matlab.visualize.task.internal.view.VisualizationPanel(...
            obj.VisualizationPanel,obj.Model);

            obj.DataView=matlab.visualize.task.internal.view.DataPanel(...
            obj.DataPanel,obj.Model);


            drawnow nocallbacks

            obj.OptionalParamView=matlab.visualize.task.internal.view.OptionalParametersPanel(...
            obj.OptionalParameterPanel,obj.Model);
        end



        function addViewListeners(obj)

            fun=@(x)addlistener(x,'ValueChangedEvent',@(e,d)obj.viewChanged());
            obj.ViewChangedListener=arrayfun(fun,[obj.VisualizationView,...
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


        function viewChanged(obj)





            notify(obj,'ViewChanged');
        end


        function visualizationChanged(obj)




            obj.Model.updateModelForVizUpdate();


            obj.DataView.updateView(obj.Model);
            obj.OptionalParamView.updateView(obj.Model);


            obj.viewChanged();
        end


        function dataChanged(obj)


            allMatchingCharts=obj.Model.findMatchingVizForData();
            obj.VisualizationView.updateState(obj.Model,allMatchingCharts);


            obj.viewChanged();
        end


        function configurationChanged(obj)

            obj.Model.updateChannelsForConfiguration();


            obj.DataView.updateSubView(obj.Model);


            obj.viewChanged();
        end


        function initializeModelAndView(obj)
            obj.Model.initModel();
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


        function delete(obj)
            delete([obj.ViewChangedListener,...
            obj.VizChangedListener,...
            obj.DataChangedListener,...
            obj.MetadataUpdatedListener,...
            obj.ConfigurationChangedListener]);
        end
    end

    methods(Hidden)








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
            outputVar='';

            chartModel=obj.Model.ChartModel;
            chartIndex=chartModel.SelectionIdx;
            dataRows=obj.Model.DataModel.getAllDataRows();


            if chartIndex>0&&~isempty(dataRows)
                chartMetaData=chartModel.ChartMetaData{chartIndex};
                chartName=chartMetaData.Name;
                if~isempty(chartMetaData.Outputs)
                    outputVar=chartMetaData.Outputs.name;
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
            end
        end



        function reset(obj)
            set(obj.VisualizationPanel,'Collapsed',false);
            set(obj.DataPanel,'Collapsed',false);
            set(obj.OptionalParameterPanel,'Collapsed',true);
            obj.Model.restoreDefaultModel();
            allMatchingCharts=obj.Model.findMatchingVizForData();
            obj.VisualizationView.updateState(obj.Model,allMatchingCharts);
            obj.updateView();
        end
    end
end