classdef HoverWaypointZ<fusion.internal.scenarioApp.canvasMode.HoverMode
    methods
        function this=HoverWaypointZ(hApp,hCanvas)
            this@fusion.internal.scenarioApp.canvasMode.HoverMode(hApp,hCanvas);
        end

        function ptr=pointerIcon(~)
            ptr='top';
        end

        function flag=hoverSuccessful(this,hSrc)
            flag=strcmp(hSrc.Tag,'waypoints.tz')&&isscalar(hSrc.UserData.TrajectorySpecification.GroundSpeed);
            if flag
                traj=hSrc.UserData.TrajectorySpecification;
                point=horzcat(traj.TimeOfArrival(1),traj.Position(1,3));
                setTooltipString(this,{hSrc.UserData.Name;getCursorTextZ(this,point)});
            end
        end

        function performButtonDown(this,hSrc,~)
            if strcmp(hSrc.Tag,'waypoints.tz')


                this.Canvas.ActiveCanvas=hSrc.Parent;
                platform=hSrc.UserData;
                if this.CurrentPlatform~=platform
                    this.CurrentPlatform=platform;
                    cancel(this);
                elseif isLeftClick(this.Canvas)
                    this.Canvas.CurrentWaypoint=1;
                    this.Canvas.CachedPosition=platform.Position;
                    setCanvasMode(this,'DragWaypointZ');
                end
            else
                cancel(this);
            end
        end
    end
end