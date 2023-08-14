classdef EnterExit<handle


    properties
Source
MotionEventName

        DoNotFireDuringDrag=true;
    end

    properties(Access=?tmatlab_graphics_interaction_uiaxes_EnterExit)
motion_listen
        last_event_valid=false;

drag_complete_listener
drag_singleton
    end

    methods(Abstract,Access=protected)
        validate(hObj,o,e);
        enter(hObj,o,e);
        exit(hObj,o,e);
    end

    methods
        function hObj=EnterExit(src,motion)
            hObj.Source=src;
            hObj.MotionEventName=motion;
            hObj.drag_singleton=matlab.graphics.interaction.uiaxes.DragSingleton.getInstance();
        end

        function enable(hObj)
            hObj.motion_listen=event.listener(hObj.Source,hObj.MotionEventName,@(o,e)motion_callback(hObj,o,e));
        end

        function disable(hObj)
            if hObj.last_event_valid
                hObj.exit();
            end
            hObj.motion_listen=[];
        end
    end

    methods(Access=private)
        function motion_callback(hObj,o,e)
            validevent=hObj.validate(o,e);
            dragenter=false;
            dragexit=false;



            if validevent&&~hObj.last_event_valid
                if hObj.DoNotFireDuringDrag&&hObj.drag_singleton.MidDrag
                    hObj.drag_complete_listener=event.listener(hObj.drag_singleton,'DragComplete',@(o,e)hObj.drag_complete(o,e));
                    dragenter=true;
                else
                    hObj.enter(o,e);
                end




            elseif~validevent&&hObj.last_event_valid
                if hObj.DoNotFireDuringDrag&&hObj.drag_singleton.MidDrag
                    hObj.drag_complete_listener=event.listener(hObj.drag_singleton,'DragComplete',@(o,e)hObj.drag_complete(o,e));
                    dragexit=true;
                else
                    hObj.exit(o,e);
                end
            end




            if(validevent&&~dragenter)||dragexit
                hObj.last_event_valid=true;
            else
                hObj.last_event_valid=false;
            end
        end

        function drag_complete(hObj,o,e)
            delete(hObj.drag_complete_listener);
            hObj.motion_callback(o,e);
        end
    end
end



