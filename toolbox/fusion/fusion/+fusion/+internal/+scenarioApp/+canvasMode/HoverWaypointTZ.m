classdef HoverWaypointTZ<fusion.internal.scenarioApp.canvasMode.HoverMode
    methods
        function this=HoverWaypointTZ(hApp,hCanvas)
            this@fusion.internal.scenarioApp.canvasMode.HoverMode(hApp,hCanvas);
        end

        function ptr=pointerIcon(~)
            ptr='circle';
        end

        function flag=hoverSuccessful(this,hSrc)
            flag=any(strcmp(hSrc.Tag,{'waypoints.tz','activewaypoint.tz'}))&&~isscalar(hSrc.UserData.TrajectorySpecification.GroundSpeed);
            if flag
                currentPoint=getCurrentPoint(this.Canvas);
                ax=this.Canvas.TZAxes;
                pos=getpixelposition(ax);
                unitsPerPixel=[diff(ax.XLim),diff(ax.YLim)]./pos(3:4);
                traj=hSrc.UserData.TrajectorySpecification;
                idx=closestTZWaypointIndex(traj,currentPoint,unitsPerPixel);
                point=horzcat(traj.TimeOfArrival(idx),traj.Position(idx,3));
                setTooltipString(this,{hSrc.UserData.Name;getWaypointCursorTextTZ(this,idx,point)});
            end
        end

        function performButtonDown(this,hSrc,~)
            if any(strcmp(hSrc.Tag,{'waypoints.tz','trajectory.tz','activewaypoint.tz'}))
                this.Canvas.ActiveCanvas=hSrc.Parent;
                platform=hSrc.UserData;
                if this.CurrentPlatform~=platform
                    this.CurrentPlatform=platform;
                    cancel(this);
                elseif isLeftClick(this.Canvas)
                    trajectory=platform.TrajectorySpecification;
                    this.Canvas.CachedTrajectory=copy(trajectory);

                    ax=this.Canvas.TZAxes;
                    pos=getpixelposition(ax);
                    unitsPerPixel=[diff(ax.XLim),diff(ax.YLim)]./pos(3:4);
                    idx=closestTZWaypointIndex(trajectory,getCurrentPoint(this.Canvas),unitsPerPixel);
                    this.Canvas.CurrentWaypoint=idx;
                    this.Canvas.CachedWaypoint=idx;
                    setCanvasMode(this,'DragWaypointTZ');
                end
            else
                cancel(this);
            end
        end
    end
end