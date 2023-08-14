classdef Player<driving.internal.scenarioApp.Display

    methods
        function this=Player(varargin)
            this@driving.internal.scenarioApp.Display(varargin{:});
        end

        function t=getTitle(~)
            t='Scenario Player';
        end

        function n=getName(~)
            n='ScenarioPlayer';
        end

    end

    methods(Access=protected)

        function size=getDefaultSize(~)
            size=[1000,800];
        end

        function h=createToolstrip(this)
            h=matlab.ui.internal.toolstrip.TabGroup;

            mainTab=h.addTab('Home');
            mainTab.Tag='home';

            mainTab.add(driving.internal.scenarioApp.SimulateSection(this));
            mainTab.add(createViewSection(this));
        end

        function h=createViewSection(this)

            import matlab.ui.internal.toolstrip.*;
            h=Section;
            h.Title='View';
            h.Tag='View';

            waypoints=CheckBox(sprintf('Waypoints'));
            centerline=CheckBox(sprintf('Center Line'));
            roadcenters=CheckBox(sprintf('Road Centers'));

            waypoints.ValueChangedFcn=@this.toggleWaypoints;
            centerline.ValueChangedFcn=@this.toggleCenterline;
            roadcenters.ValueChangedFcn=@this.toggleRoadEditPoints;

            column=h.addColumn;

            column.add(waypoints);
            column.add(centerline);
            column.add(roadcenters);
        end

        function toggleWaypoints(this,~,~)
            scenarioView=this.ScenarioView;
            scenarioView.ShowWaypoints=~scenarioView.ShowWaypoints;
            this.EgoCentricView.ShowWaypoints=scenarioView.ShowWaypoints;
        end

        function toggleCenterline(this,~,~)
            scenarioView=this.ScenarioView;
            scenarioView.ShowCenterline=~scenarioView.ShowCenterline;
            this.EgoCentricView.ShowCenterline=scenarioView.ShowCenterline;
        end

        function toggleRoadEditPoints(this,~,~)
            scenarioView=this.ScenarioView;
            scenarioView.ShowRoadEditPoints=~scenarioView.ShowRoadEditPoints;
            this.EgoCentricView.ShowRoadEditPoints=scenarioView.ShowRoadEditPoints;
        end
    end
end


