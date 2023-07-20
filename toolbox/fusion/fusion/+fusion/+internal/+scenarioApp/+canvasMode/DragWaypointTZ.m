classdef DragWaypointTZ<fusion.internal.scenarioApp.canvasMode.CanvasMode
    methods
        function this=DragWaypointTZ(hApp,hCanvas)
            this@fusion.internal.scenarioApp.canvasMode.CanvasMode(hApp,hCanvas);
        end

        function ptr=pointerIcon(~)
            ptr='hand';
        end

        function performMouseMove(this,src,evt)%#ok<INUSD>
            currentPoint=getCurrentPoint(this.Canvas);
            setCurrentWaypointTZ(this.Application,currentPoint);
            idx=getCurrentWaypoint(this.Application);
            traj=this.CurrentPlatform.TrajectorySpecification;
            tz=horzcat(traj.TimeOfArrival(idx),traj.Position(idx,3));
            setTooltipString(this,getWaypointCursorTextTZ(this,idx,tz));
        end

        function performButtonDown(this,~,~)
            cancel(this);
        end

        function performButtonUp(this,src,evt)%#ok<INUSD>
            currentPoint=getCurrentPoint(this.Canvas);

            newTraj=this.CurrentPlatform.TrajectorySpecification;
            idx=getCurrentWaypoint(this.Application);
            newTraj.Position(idx,3)=currentPoint(2);
            newIdx=reassignTimeIndex(newTraj,idx,currentPoint(1));
            oldIdx=this.Canvas.CachedWaypoint;
            oldTraj=this.Canvas.CachedTrajectory;

            changeTrajectory(this.Application,newIdx,newTraj,oldIdx,oldTraj);

            setCanvasMode(this,'Explore');
        end

        function cancel(~)

        end
    end
end