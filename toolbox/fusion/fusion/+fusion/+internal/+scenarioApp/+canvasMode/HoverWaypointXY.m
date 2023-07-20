classdef HoverWaypointXY<fusion.internal.scenarioApp.canvasMode.HoverMode
    methods
        function this=HoverWaypointXY(hApp,hCanvas)
            this@fusion.internal.scenarioApp.canvasMode.HoverMode(hApp,hCanvas);
        end

        function ptr=pointerIcon(~)
            ptr='circle';
        end

        function flag=hoverSuccessful(this,hSrc)
            flag=any(strcmp(hSrc.Tag,{'waypoints.xy','activewaypoint.xy'}));
            if flag
                currentPoint=getCurrentPoint(this.Canvas);
                traj=hSrc.UserData.TrajectorySpecification;
                idx=closestXYWaypointIndex(traj,currentPoint);
                setTooltipString(this,getWaypointCursorTextXY(this,idx,traj.Position(idx,:)));
            end
        end

        function performButtonDown(this,hSrc,~)
            if any(strcmp(hSrc.Tag,{'trajectory.xy','waypoints.xy','activewaypoint.xy'}))
                this.Canvas.ActiveCanvas=hSrc.Parent;
                platform=hSrc.UserData;
                if this.CurrentPlatform~=platform
                    this.CurrentPlatform=platform;
                    cancel(this);
                elseif isLeftClick(this.Canvas)
                    trajectory=platform.TrajectorySpecification;
                    this.Canvas.CachedTrajectory=copy(trajectory);
                    this.Canvas.CurrentWaypoint=closestXYWaypointIndex(trajectory,getCurrentPoint(this.Canvas));
                    setCanvasMode(this,'DragWaypointXY');
                end
            else
                cancel(this);
            end
        end
    end
end