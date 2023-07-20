classdef ClickEvent<matlab.graphics.interaction.uiaxes.InteractionEvent


    properties(Access=?tmatlab_graphics_interaction_uiaxes_ClickEvent)
down_listener
up_listener

down_eventname
up_eventname

        down_point double=[NaN,NaN];
        down_selectiontype string

control_listener
shift_listener
alt_listener
    end

    properties
        doubleclick(1,1)logical=false;
    end

    properties(SetAccess=private)
        EventName='click';
    end

    events
click
    end

    methods
        function hObj=ClickEvent(obj,downeventname,upeventname)
            hObj.source=obj;

            hObj.down_eventname=downeventname;
            hObj.up_eventname=upeventname;
        end

        function enable(hObj)
            import matlab.graphics.interaction.uiaxes.*;

            hObj.down_listener=event.listener(hObj.source,hObj.down_eventname,@hObj.downeventcallback);
            hObj.up_listener=event.listener(hObj.source,hObj.up_eventname,@hObj.upeventcallback);
            hObj.control_listener=ModifierKeyListener(hObj.source,'control');
            hObj.shift_listener=ModifierKeyListener(hObj.source,'shift');
            hObj.alt_listener=ModifierKeyListener(hObj.source,'alt');

            hObj.control_listener.enable();
            hObj.shift_listener.enable();
            hObj.alt_listener.enable();
        end

        function disable(hObj)
            hObj.down_listener=[];
            hObj.up_listener=[];
            hObj.control_listener=[];
            hObj.shift_listener=[];
            hObj.alt_listener=[];
        end
    end

    methods(Access=?tmatlab_graphics_interaction_uiaxes_ClickEvent)
        function downeventcallback(hObj,o,e)
            hObj.down_point=e.Point;
            seltype=o.SelectionType;


            if~strcmp(seltype,'open')
                hObj.down_selectiontype=seltype;
            end
        end

        function upeventcallback(hObj,o,e)




            if all(hObj.down_point==e.Point)&&...
                (~hObj.doubleclick||(hObj.doubleclick&&strcmp(o.SelectionType,'open')&&(isempty(hObj.down_selectiontype)||strcmp(hObj.down_selectiontype,'normal'))))
                newe=matlab.graphics.interaction.uiaxes.MouseEventData(o,e,hObj.control_listener.iskeypressed,hObj.shift_listener.iskeypressed,hObj.alt_listener.iskeypressed);
                notify(hObj,'click',newe);
            end
        end
    end
end
