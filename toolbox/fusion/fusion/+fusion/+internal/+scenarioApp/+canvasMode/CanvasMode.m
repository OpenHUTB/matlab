classdef CanvasMode<handle

    properties
Application
Canvas
    end

    properties(Dependent,Transient)
CurrentPlatform
    end

    methods
        function this=CanvasMode(hApp,hCanvas)
            this.Application=hApp;
            this.Canvas=hCanvas;
        end

        function update(this)
            set(this.Canvas.Figure,'Pointer',pointerIcon(this));
        end

        function accept(this)

            hSrc=hittest(this.Canvas.Figure);
            performButtonUp(this,hSrc)
            performButtonDown(this,hSrc)
        end

        function discard(this)
        end

        function value=get.CurrentPlatform(this)
            value=getCurrentPlatform(this.Application);
        end

        function set.CurrentPlatform(this,value)
            setCurrentPlatform(this.Application,value);
        end
    end

    methods(Hidden)
        function[tooltip,cp]=getWaypointCursorTextXY(~,idx,cp)
            tooltip="["+num2str(idx)+"] X: "+num2str(cp(1))+", "+"Y: "+num2str(cp(2));
        end

        function[tooltip,cp]=getCursorTextXY(~,cp)
            tooltip="X: "+num2str(cp(1))+", "+"Y: "+num2str(cp(2));
        end

        function[tooltip,cp]=getWaypointCursorTextTZ(~,idx,cp)
            tooltip="["+num2str(idx)+"] T: "+num2str(cp(1))+", "+"Z: "+num2str(cp(2));
        end

        function[tooltip,cp]=getCursorTextZ(~,cp)
            tooltip="Z: "+num2str(cp(2));
        end

        function[tooltip,cp]=getCursorTextT(~,cp)
            tooltip="T: "+num2str(cp(1));
        end

        function[tooltip,cp]=getCursorTextTZ(~,cp)
            tooltip="T:"+num2str(cp(1))+", "+"Z:"+num2str(cp(2));
        end


        function setTooltipString(this,newString)
            setTooltipString(this.Canvas,newString);
        end


        function setCanvasMode(this,newMode)
            restoreContextMenus(this.Canvas);
            setCanvasMode(this.Canvas,newMode);
        end

        function cancelButtonDown(this)
            cancel(this);
        end
    end

    methods(Abstract)
        performMouseMove(this,src,evt)
        performButtonDown(this,src,evt)
        performButtonUp(this,src,evt)
        pointerIcon(this)
        cancel(this)
    end
end