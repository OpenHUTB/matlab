classdef TrajectoryPathSection<fusion.internal.scenarioApp.toolstrip.Section

    properties
Enabled
    end

    properties(SetAccess=protected,Hidden)
WaypointButton
DeleteButton
    end

    methods
        function this=TrajectoryPathSection(hApplication,hToolstrip)
            this@fusion.internal.scenarioApp.toolstrip.Section(hApplication,hToolstrip);
            hApp=this.Application;

            import matlab.ui.internal.toolstrip.*;
            this.Title=msgString(this,'TrajectoryPathSectionTitle');
            this.Tag='trajectorypath';


            addWaypoint=Button(msgString(this,'WaypointsButton'),...
            Icon(fullfile(this.IconDirectory,'add_waypoints_24_1.png')));
            addWaypoint.Description=msgString(this,'WaypointsDescription');
            addWaypoint.Tag='waypoints';
            addWaypoint.ButtonPushedFcn=hApp.initCallback(@this.addWaypointsCallback);
            addWaypoint.Enabled=~isempty(getCurrentPlatform(hApp));
            this.WaypointButton=addWaypoint;


            deleteButton=Button(msgString(this,'DeleteTrajectory'),...
            Icon.DELETE_24);
            deleteButton.Description=msgString(this,'DeleteTrajectoryDescription');
            deleteButton.Tag='deletetrajectory';
            deleteButton.ButtonPushedFcn=hApp.initCallback(@this.deleteTrajectory);
            curplat=getCurrentPlatform(hApp);
            deleteButton.Enabled=~isempty(curplat)&&...
            ~isempty(curplat.TrajectorySpecification.HorizontalCumulativeDistance);
            this.DeleteButton=deleteButton;


            col1=addColumn(this,'HorizontalAlignment','center');
            add(col1,addWaypoint);

            col2=addColumn(this,'HorizontalAlignment','right');
            add(col2,deleteButton);
            this.Enabled=true;
        end

        function update(this,hasPlatforms)
            this.WaypointButton.Enabled=this.Enabled&&hasPlatforms;
            currentPlatform=this.Application.DataModel.CurrentPlatform;
            enableSection=~isempty(currentPlatform);
            if enableSection
                traj=currentPlatform.TrajectorySpecification;
                this.DeleteButton.Enabled=~isStationary(traj);
            else
                this.DeleteButton.Enabled=false;
            end
        end

    end


    methods(Access=private)
        function addWaypointsCallback(this,~,~)
            requestWaypoints(this.Application);
        end

        function deleteTrajectory(this,~,~)
            deleteCurrentTrajectory(this.Application);
        end

    end
end
