classdef ViewModel<handle










    properties
PlatformPanel
SensorPanel
SensorCanvas
ScenarioCanvas
ScenarioView
    end

    methods
        function this=ViewModel
            this.PlatformPanel=fusion.internal.scenarioApp.viewModel.PlatformPanelModel;
            this.SensorPanel=fusion.internal.scenarioApp.viewModel.SensorPanelModel;
            this.ScenarioCanvas=fusion.internal.scenarioApp.viewModel.ScenarioCanvasModel;
            this.ScenarioView=fusion.internal.scenarioApp.viewModel.ScenarioViewModel;
        end
    end
end