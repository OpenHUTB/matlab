classdef DragCursor<matlab.graphics.interaction.uiaxes.Drag&matlab.graphics.interaction.uiaxes.InteractionBase


    properties
cursor
    end

    properties(SetAccess=private)
ax
    end

    methods
        function hObj=DragCursor(ax,cursor)
            hObj=hObj@matlab.graphics.interaction.uiaxes.InteractionBase;
            fig=ancestor(ax,'figure');
            hObj=hObj@matlab.graphics.interaction.uiaxes.Drag(fig,'WindowMousePress','WindowMouseMotion','WindowMouseRelease');
            hObj.ax=ax;
            hObj.cursor=cursor;
        end
    end

    methods(Access=protected)
        function c=start(~,o,~)
            c.oldcursor=o.Pointer;
        end

        function move(hObj,o,~,~)
            setptr(o,hObj.cursor);
        end

        function ret=validate(hObj,o,e)
            ret=hObj.strategy.isValidMouseEvent(hObj,o,e);
        end

        function stop(~,o,~,c)
            o.Pointer=c.oldcursor;
        end

        function cancel(~,~,~),end
    end
end

