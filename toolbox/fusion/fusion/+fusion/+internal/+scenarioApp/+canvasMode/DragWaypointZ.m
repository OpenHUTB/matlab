classdef DragWaypointZ<fusion.internal.scenarioApp.canvasMode.CanvasMode
    methods
        function this=DragWaypointZ(hApp,hCanvas)
            this@fusion.internal.scenarioApp.canvasMode.CanvasMode(hApp,hCanvas);
        end

        function ptr=pointerIcon(~)
            ptr='hand';
        end

        function performMouseMove(this,src,evt)%#ok<INUSD>

            currentPoint=getCurrentPoint(this.Canvas);
            setTooltipString(this,getCursorTextZ(this,currentPoint))
            setCurrentPositionZ(this.Application,currentPoint(2));
        end

        function performButtonDown(this,~,~)
            cancel(this);
        end

        function performButtonUp(this,~,~)

            currentPoint=getCurrentPoint(this.Canvas);
            oldPos=this.Canvas.CachedPosition;


            newPos=horzcat(oldPos(1:2),currentPoint(2));



            this.Application.setPlatformProperty('Position',newPos,oldPos);


            setCanvasMode(this,'Explore');
            this.Canvas.ActiveCanvas=[];
        end

        function cancel(this)
            setCurrentPositionZ(this.Application,this.Canvas.CachedPosition(3));
            setCanvasMode(this,'Explore');
        end
    end
end