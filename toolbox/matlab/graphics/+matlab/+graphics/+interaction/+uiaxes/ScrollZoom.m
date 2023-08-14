classdef ScrollZoom<handle



    properties
Axes

        Enabled=false
scroll_eventobject
    end

    properties(SetAccess=private)
zoom_handle

scroll_listener
    end

    properties(Dependent)
strategy
zoom_factor
Dimensions
    end

    methods
        function hObj=ScrollZoom(ax,obj,scrolleventname,motioneventname)
            hObj.zoom_handle=matlab.graphics.interaction.uiaxes.SingleActionZoom(ax);
            hObj.zoom_handle.zoom_factor=1.1;


            if nargin>3
                hObj.scroll_eventobject=matlab.graphics.interaction.uiaxes.ScrollEvent(obj,scrolleventname,motioneventname);
            else
                hObj.scroll_eventobject=matlab.graphics.interaction.uiaxes.ScrollEvent(obj,scrolleventname);
            end
            hObj.scroll_eventobject.enable();
        end

        function enable(hObj)
            hObj.scroll_listener=event.listener(hObj.scroll_eventobject,'scroll',@(o,e)hObj.scroll_callback(o,e));
            hObj.Enabled=true;
        end

        function hObj=disable(hObj)
            hObj.scroll_listener=[];
            hObj.Enabled=false;
        end

        function set.strategy(hObj,val)
            hObj.zoom_handle.strategy=val;
        end

        function val=get.strategy(hObj)
            val=hObj.zoom_handle.strategy;
        end

        function set.zoom_factor(hObj,val)
            hObj.zoom_handle.zoom_factor=val;
        end

        function val=get.zoom_factor(hObj)
            val=hObj.zoom_handle.zoom_factor;
        end

        function set.Dimensions(hObj,val)
            hObj.zoom_handle.Dimensions=val;
        end

        function val=get.Dimensions(hObj)
            val=hObj.zoom_handle.Dimensions;
        end
    end

    methods(Access=private)
        function scroll_callback(hObj,o,e)
            invert=e.VerticalScrollCount>0;
            hObj.zoom_handle.apply(o,e,invert);
            matlab.graphics.interaction.internal.setInteractiveDDUXData(hObj.Axes,'scrollzoom','default');
        end
    end
end
