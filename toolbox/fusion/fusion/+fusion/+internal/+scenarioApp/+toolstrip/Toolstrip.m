classdef Toolstrip<matlab.ui.internal.toolstrip.TabGroup



    properties
Application
        isSimMode logical=false
    end

    properties(SetAccess=protected,Hidden)

MainTab
TrajectoryTab
SimulationTab


FileSection
PlatformSection
SelectionSection
SensorSection
RunSection
LayoutSection
ExportSection


SelectionSectionTraj
TrajectoryPathSection
TrajectorySpeedSection
TrajectoryOrientSection
TrajectoryLayoutSection


SimulateSection
ExitSimulateSection


    end

    properties(Constant,Hidden)
        ResourceCatalog='fusion:trackingScenarioApp:Toolstrip:'
    end

    methods
        function this=Toolstrip(hApp,varargin)

            this@matlab.ui.internal.toolstrip.TabGroup();

            this.Application=hApp;
            this.Tag=getName(hApp);

            mainTab=this.addTab(msgString(this,'Designer'));
            mainTab.Tag='homeTab';

            this.FileSection=getFileSection(hApp);
            this.PlatformSection=fusion.internal.scenarioApp.toolstrip.PlatformSection(hApp,this);
            this.SensorSection=fusion.internal.scenarioApp.toolstrip.SensorSection(hApp,this);
            this.SelectionSection=fusion.internal.scenarioApp.toolstrip.SelectionSection(hApp,this);
            this.LayoutSection=fusion.internal.scenarioApp.toolstrip.LayoutSection(hApp,this);
            this.ExportSection=fusion.internal.scenarioApp.toolstrip.ExportSection(hApp,this);
            this.RunSection=fusion.internal.scenarioApp.toolstrip.RunSection(hApp,this);

            mainTab.add(this.FileSection);
            mainTab.add(this.PlatformSection);
            mainTab.add(this.SelectionSection);
            mainTab.add(this.SensorSection);

            mainTab.add(this.RunSection);
            mainTab.add(this.LayoutSection);
            mainTab.add(this.ExportSection);


            trajTab=this.addTab(msgString(this,'Trajectory'));
            trajTab.Tag='trajectoryTab';
            this.TrajectoryPathSection=fusion.internal.scenarioApp.toolstrip.TrajectoryPathSection(hApp,this);
            this.TrajectorySpeedSection=fusion.internal.scenarioApp.toolstrip.TrajectorySpeedSection(hApp,this);
            this.TrajectoryOrientSection=fusion.internal.scenarioApp.toolstrip.TrajectoryOrientSection(hApp,this);
            this.TrajectoryLayoutSection=fusion.internal.scenarioApp.toolstrip.TrajectoryLayoutSection(hApp,this);
            this.SelectionSectionTraj=fusion.internal.scenarioApp.toolstrip.SelectionSection(hApp,this);


            trajTab.add(this.SelectionSectionTraj);
            trajTab.add(this.TrajectoryPathSection);
            trajTab.add(this.TrajectoryOrientSection);
            trajTab.add(this.TrajectorySpeedSection);
            trajTab.add(this.TrajectoryLayoutSection);


            simTab=matlab.ui.internal.toolstrip.Tab(msgString(this,'Simulation'));
            simTab.Tag='simulationTab';
            this.SimulateSection=fusion.internal.scenarioApp.toolstrip.SimulateSection(hApp,this);
            this.ExitSimulateSection=fusion.internal.scenarioApp.toolstrip.ExitSimulateSection(hApp,this);
            simTab.add(this.SimulateSection);
            simTab.add(this.ExitSimulateSection);

            this.MainTab=mainTab;
            this.SimulationTab=simTab;
            this.TrajectoryTab=trajTab;
        end

        function update(this,platformItems,sensorItems)
            switch this.isSimMode
            case 0
                hasPlatform=~isempty(platformItems);
                update(this.PlatformSection);
                update(this.SensorSection,hasPlatform);
                update(this.ExportSection,hasPlatform);
                update(this.TrajectoryPathSection,~isempty(platformItems));
                update(this.TrajectorySpeedSection);
                update(this.TrajectoryOrientSection);
                update(this.SelectionSection,platformItems,sensorItems);
                update(this.SelectionSectionTraj,platformItems,sensorItems);
                update(this.RunSection);
            case 1

                update(this.SimulateSection);
            end

        end

        function updateSimulator(this)
            updateSimulator(this.SimulateSection);
        end

        function switchSimMode(this,state)
            if strcmp(state,'on')&&~this.isSimMode
                this.remove(this.TrajectoryTab);
                this.remove(this.MainTab);
                this.add(this.SimulationTab);
                this.isSimMode=true;
            elseif strcmp(state,'off')&&this.isSimMode
                this.remove(this.SimulationTab);
                this.add(this.MainTab);
                this.add(this.TrajectoryTab);
                this.isSimMode=false;
            end
        end
    end


    methods(Hidden)
        function str=msgString(this,tagPrefix,varargin)
            str=getString(message(strcat(this.ResourceCatalog,tagPrefix),varargin{:}));
        end
    end
end
