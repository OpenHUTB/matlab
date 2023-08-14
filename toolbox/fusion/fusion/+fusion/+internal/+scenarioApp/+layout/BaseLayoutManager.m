classdef BaseLayoutManager<handle



    properties
Application

PlatformPanel
SensorPanel
ScenarioCanvas
TrajectoryTable
ScenarioView
SensorCanvas
    end

    methods(Abstract)
        updateComponents(this,notFirstCall)
        updateTrajectoryTableComponent(this,state)
        updateSensorComponents(this,visible)
        layoutSimulation(this)
        getPositionAroundCenter(this,size)
    end

    methods
        function this=BaseLayoutManager(hApp)
            this.Application=hApp;
        end

        function components=createDefaultComponents(this)
            hApp=this.Application;

            platformPanel=fusion.internal.scenarioApp.component.PlatformPanel(hApp);
            sensorPanel=fusion.internal.scenarioApp.component.SensorPanel(hApp);

            scenarioCanvas=fusion.internal.scenarioApp.component.ScenarioCanvas(hApp);
            trajectoryTable=fusion.internal.scenarioApp.component.TrajectoryTable(hApp);

            scenarioView=fusion.internal.scenarioApp.component.ScenarioView(hApp);
            sensorCanvas=fusion.internal.scenarioApp.component.SensorCanvas(hApp);

            components=[scenarioCanvas,sensorCanvas,platformPanel,sensorPanel...
            ,scenarioView,trajectoryTable];

            this.PlatformPanel=platformPanel;
            this.SensorPanel=sensorPanel;
            this.ScenarioCanvas=scenarioCanvas;
            this.TrajectoryTable=trajectoryTable;
            this.ScenarioView=scenarioView;
            this.SensorCanvas=sensorCanvas;
        end
    end
end

