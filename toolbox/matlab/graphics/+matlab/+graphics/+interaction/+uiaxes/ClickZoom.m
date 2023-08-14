classdef ClickZoom<handle


    properties
        Enabled=false
    end

    properties(Access=private)
zoom_handle

click_eventobject
click_listener
    end

    properties(Dependent)
doubleclick
zoom_factor
strategy
    end

    methods
        function hObj=ClickZoom(ax,obj,downeventname,upeventname)
            hObj.zoom_handle=matlab.graphics.interaction.uiaxes.SingleActionZoom(ax);
            hObj.zoom_handle.zoom_factor=3/2;


            hObj.click_eventobject=matlab.graphics.interaction.uiaxes.ClickEvent(obj,downeventname,upeventname);
            hObj.click_eventobject.enable();
        end

        function enable(hObj)
            hObj.click_listener=event.listener(hObj.click_eventobject,'click',@(o,e)hObj.click_callback(o,e));
            hObj.Enabled=true;
        end

        function hObj=disable(hObj)
            hObj.click_listener=[];
            hObj.Enabled=false;
        end

        function ret=get.doubleclick(hObj)
            ret=hObj.click_eventobject.doubleclick;
        end

        function set.doubleclick(hObj,val)
            hObj.click_eventobject.doubleclick=val;
        end

        function ret=get.zoom_factor(hObj)
            ret=hObj.zoom_handle.zoom_factor;
        end

        function set.zoom_factor(hObj,val)
            hObj.zoom_handle.zoom_factor=val;
        end

        function set.strategy(hObj,val)
            hObj.zoom_handle.strategy=val;
        end

        function val=get.strategy(hObj)
            val=hObj.zoom_handle.strategy;
        end
    end

    methods(Access=private)
        function click_callback(hObj,o,e)
            invert=e.ShiftPressed;
            hObj.zoom_handle.apply(o,e,invert)
        end
    end
end
