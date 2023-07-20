classdef JSLayoutManager<fusion.internal.scenarioApp.layout.BaseLayoutManager



    methods
        function updateComponents(this,notFirstCall)

            if~notFirstCall


                allFigs=[this.PlatformPanel.Figure;
                this.SensorPanel.Figure;
                this.ScenarioCanvas.Figure;
                this.SensorCanvas.Figure;
                this.ScenarioView.Figure;
                this.TrajectoryTable.Figure];
                set(allFigs,'Visible','on');



                pause(0.2);
                addComponent(this.Application,this.PlatformPanel);
                addComponent(this.Application,this.ScenarioCanvas);
                addComponent(this.Application,this.ScenarioView);
                addComponent(this.Application,this.SensorPanel);
                addComponent(this.Application,this.SensorCanvas);
                addComponent(this.Application,this.TrajectoryTable);


                showComponent(this.Application,this.PlatformPanel);
                showComponent(this.Application,this.ScenarioCanvas);
                showComponent(this.Application,this.ScenarioView);
                hideComponent(this.Application,this.SensorPanel);
                hideComponent(this.Application,this.SensorCanvas);
                hideComponent(this.Application,this.TrajectoryTable);

                doLayout(this);
            end
        end

        function updateTrajectoryTableComponent(this,state)
            if strcmpi(state,'off')
                hideComponent(this.Application,this.TrajectoryTable);
                doLayout(this);
            elseif strcmpi(state,'on')
                showComponent(this.Application,this.TrajectoryTable);
                doLayout(this);
            end
        end

        function updateSensorComponents(this,visible)


            if nargin<2
                visible=true;
            end

            if visible
                this.SensorPanel.Figure.Visible='on';
                this.SensorCanvas.Figure.Visible='on';
                panelShown=showComponent(this.Application,this.SensorPanel);
                canvasShown=showComponent(this.Application,this.SensorCanvas);
                if panelShown||canvasShown
                    doLayout(this);
                end
            else
                this.SensorPanel.Figure.Visible='off';
                this.SensorCanvas.Figure.Visible='off';
                panelHidden=hideComponent(this.Application,this.SensorPanel);
                canvasHidden=hideComponent(this.Application,this.SensorCanvas);
                if panelHidden||canvasHidden
                    doLayout(this);
                end
            end
        end

        function doLayout(this)

            updateComponentVisibility(this.Application,this.PlatformPanel);
            updateComponentVisibility(this.Application,this.ScenarioCanvas);
            updateComponentVisibility(this.Application,this.ScenarioView);
            updateComponentVisibility(this.Application,this.SensorPanel);
            updateComponentVisibility(this.Application,this.SensorCanvas);
            updateComponentVisibility(this.Application,this.TrajectoryTable);

            tiles={};

            tiles{1}=[this.PlatformPanel,this.SensorPanel];

            tiles{2}=[this.ScenarioCanvas,this.SensorCanvas];

            tiles{3}=this.ScenarioView;

            if matlab.lang.OnOffSwitchState(this.TrajectoryTable.Figure.Visible)
                tiles{4}=this.TrajectoryTable;
                gridHeight=2;
                rowWeights=[.66,.34];
                tileCoverage=[1,2,3;1,4,3];
            else
                gridHeight=1;
                rowWeights=1;
                tileCoverage=[1,2,3];
            end

            appContainer=this.Application.Window.AppContainer;
            pause(2);
            appContainer.DocumentLayout=struct(...
            'gridDimensions',struct('w',3,'h',gridHeight),...
            'columnWeights',[0.25,.40,.35],...
            'rowWeights',rowWeights,...
            'tileCount',numel(tiles),...
            'tileCoverage',tileCoverage,...
            'tileOccupancy',{getTileOccupancy(this.Application.Window,...
            tiles{:})});
        end

        function layoutSimulation(this)
            hideComponent(this.Application,this.SensorPanel);
            hideComponent(this.Application,this.PlatformPanel);
            hideComponent(this.Application,this.ScenarioCanvas);
            hideComponent(this.Application,this.SensorCanvas);
            hideComponent(this.Application,this.TrajectoryTable);
            appContainer=this.Application.Window.AppContainer;
            appContainer.DocumentLayout=struct(...
            'gridDimensions',struct('w',1,'h',1),...
            'rowWeights',1,...
            'tileCount',1,...
            'tileCoverage',1,...
            'tileOccupancy',{...
            getTileOccupancy(this.Application.Window,...
            this.ScenarioView)});
        end

        function pos=getPositionAroundCenter(this,size)

            pos=matlabshared.application.getCenterPosition(...
            size,...
            this.Application.Window.AppContainer.WindowBounds);
        end

    end
end
