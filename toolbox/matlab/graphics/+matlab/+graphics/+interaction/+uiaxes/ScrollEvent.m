
classdef ScrollEvent<matlab.graphics.interaction.uiaxes.InteractionEvent


    properties(SetAccess=private)
motioneventname
action

motion_listener
scroll_listener

MotionEventData
    end

    properties(SetAccess=private)
        EventName='scroll';
    end

    events
scroll
    end

    methods
        function hObj=ScrollEvent(obj,scrolleventname,motioneventname)
            hObj.source=obj;
            hObj.eventname=scrolleventname;
            if nargin>2
                hObj.motioneventname=motioneventname;
            end
        end
        function enable(hObj)
            if~isempty(hObj.motioneventname)
                hObj.motion_listener=event.listener(hObj.source,hObj.motioneventname,@(o,e)hObj.motioncallback(o,e));
            end
            hObj.scroll_listener=event.listener(hObj.source,hObj.eventname,@(o,e)hObj.scroll_callback(o,e));
        end

        function hObj=disable(hObj)
            hObj.motion_listener=[];
            hObj.scroll_listener=[];
        end
    end

    methods(Access=private)
        function scroll_callback(hObj,o,e)

            if~isprop(e,'PointInPixels')&&~isempty(hObj.motioneventname)&&~isempty(hObj.MotionEventData)
                newe=matlab.graphics.interaction.uiaxes.ScrollEventData(o,hObj.MotionEventData,e.VerticalScrollCount);
            elseif isprop(e,'Chart')


                newe=matlab.internal.editor.figure.ScrollEventWrapper(e,e.Chart);
            elseif isprop(e,'PointInPixels')

                newe=e;
            else
                return
            end
            notify(hObj,'scroll',newe);
        end

        function motioncallback(hObj,~,e)
            hObj.MotionEventData=e;
        end
    end
end

