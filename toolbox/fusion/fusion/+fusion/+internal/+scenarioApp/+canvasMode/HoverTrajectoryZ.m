classdef HoverTrajectoryZ<fusion.internal.scenarioApp.canvasMode.HoverMode
    methods
        function this=HoverTrajectoryZ(hApp,hCanvas)
            this@fusion.internal.scenarioApp.canvasMode.HoverMode(hApp,hCanvas);
        end

        function ptr=pointerIcon(~)
            ptr='top';
        end

        function flag=hoverSuccessful(this,hSrc)
            flag=strcmp(hSrc.Tag,'trajectory.tz');
            if flag
                currentPoint=getCurrentPoint(this.Canvas);
                traj=hSrc.UserData.TrajectorySpecification;
                if isscalar(traj.TimeOfArrival)
                    currentPoint(2)=traj.Position(1,3);
                else
                    position=lookupPose(traj,currentPoint(1));
                    if~isnan(position)
                        currentPoint(2)=position(3);
                    end
                end
                setTooltipString(this,{hSrc.UserData.Name;getCursorTextZ(this,currentPoint)});
            end
        end

        function performButtonDown(this,hSrc,~)
            if strcmp(hSrc.Tag,'trajectory.tz')
                this.Canvas.ActiveCanvas=hSrc.Parent;
                platform=hSrc.UserData;
                if this.CurrentPlatform~=platform
                    this.CurrentPlatform=platform;
                    cancel(this);
                elseif isLeftClick(this.Canvas)
                    trajectory=platform.TrajectorySpecification;
                    this.Canvas.CachedPosition=getCurrentPoint(this.Canvas);
                    this.Canvas.CachedTrajectory=copy(trajectory);
                    setCanvasMode(this,'DragTrajectoryZ');
                end
            else
                cancel(this);
            end
        end
    end
end