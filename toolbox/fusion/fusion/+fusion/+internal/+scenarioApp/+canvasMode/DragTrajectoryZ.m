classdef DragTrajectoryZ<fusion.internal.scenarioApp.canvasMode.CanvasMode
    methods
        function this=DragTrajectoryZ(hApp,hCanvas)
            this@fusion.internal.scenarioApp.canvasMode.CanvasMode(hApp,hCanvas);
        end

        function ptr=pointerIcon(~)
            ptr='hand';
        end

        function performMouseMove(this,src,evt)%#ok<INUSD>
            currentPoint=getCurrentPoint(this.Canvas);
            setTooltipString(this,getCursorTextZ(this,currentPoint));
            offset=[0,0,currentPoint(2)-this.Canvas.CachedPosition(2)];
            moveCurrentTrajectory(this.Application,this.Canvas.CachedTrajectory,offset);
        end

        function performButtonDown(this,~,~)
            cancel(this);
        end

        function performButtonUp(this,src,evt)%#ok<INUSD>
            currentPoint=getCurrentPoint(this.Canvas);
            oldTraj=this.Canvas.CachedTrajectory;
            newTraj=copy(oldTraj);
            newTraj.Position=newTraj.Position+[0,0,currentPoint(2)-this.Canvas.CachedPosition(2)];
            autoAdjust(newTraj);
            changeTrajectory(this.Application,0,newTraj,0,oldTraj);
            setCanvasMode(this,'Explore');
        end

        function cancel(this)
            moveCurrentTrajectory(this.Application,this.Canvas.CachedTrajectory,zeros(1,3));
            setCanvasMode(this,'Explore');
        end
    end
end