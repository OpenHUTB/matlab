classdef HoverTrajectoryXY<fusion.internal.scenarioApp.canvasMode.HoverMode
    methods
        function this=HoverTrajectoryXY(hApp,hCanvas)
            this@fusion.internal.scenarioApp.canvasMode.HoverMode(hApp,hCanvas);
        end

        function ptr=pointerIcon(~)
            ptr='fleur';
        end

        function flag=hoverSuccessful(this,hSrc)
            flag=strcmp(hSrc.Tag,'trajectory.xy');
            if flag
                currentPoint=getCurrentPoint(this.Canvas);
                setTooltipString(this,getCursorTextXY(this,currentPoint));
            end
        end

        function performButtonDown(this,hSrc,~)
            if any(strcmp(hSrc.Tag,{'trajectory.xy','waypoints.xy'}))
                this.Canvas.ActiveCanvas=hSrc.Parent;
                platform=hSrc.UserData;
                if this.CurrentPlatform~=platform
                    this.CurrentPlatform=platform;
                    cancel(this);
                elseif isLeftClick(this.Canvas)
                    trajectory=platform.TrajectorySpecification;
                    this.Canvas.CachedPosition=getCurrentPoint(this.Canvas);
                    this.Canvas.CachedTrajectory=copy(trajectory);
                    setCanvasMode(this,'DragTrajectoryXY');
                end
            else
                cancel(this);
            end
        end
    end
end