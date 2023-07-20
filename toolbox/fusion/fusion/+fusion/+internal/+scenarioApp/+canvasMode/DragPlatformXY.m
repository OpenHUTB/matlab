classdef DragPlatformXY<fusion.internal.scenarioApp.canvasMode.CanvasMode
    methods
        function this=DragPlatformXY(hApp,hCanvas)
            this@fusion.internal.scenarioApp.canvasMode.CanvasMode(hApp,hCanvas);
        end

        function ptr=pointerIcon(~)
            ptr='hand';
        end

        function performMouseMove(this,src,evt)%#ok<INUSD>
            currentPoint=getCurrentPoint(this.Canvas);
            setTooltipString(this,getCursorTextXY(this,currentPoint))
            setCurrentPositionXY(this.Application,currentPoint(1:2));
        end

        function performButtonDown(~,~,~)

        end

        function performButtonUp(this,src,evt)%#ok<INUSD>

            currentPoint=getCurrentPoint(this.Canvas);
            oldPos=this.Canvas.CachedPosition;


            newPos=horzcat(currentPoint(1:2),oldPos(3));



            setPlatformProperty(this.Application,'Position',newPos,oldPos);


            setCanvasMode(this,'Explore');
        end

        function cancel(this)
            setCurrentPositionXY(this.Application,this.Canvas.CachedPosition(1:2));
            setCanvasMode(this,'Explore');
        end
    end
end