classdef(Abstract)Drag<handle



    properties(SetAccess=private)
source

downeventname
moveeventname
upeventname

        Enabled=false
    end

    properties(Access=private)
start_listen
move_listen
stop_listen
cancel_listen

drag_singleton

custom_event_data
last_event_data
    end

    methods(Abstract,Access=protected)
        validate(hObj,o,e);
        ced=start(hObj,o,e,c);
        move(hObj,o,e,ced);
        stop(hObj,o,e,ced);
        cancel(hObj,o,e,ced);
    end

    methods
        function hObj=Drag(listen_obj,downevent,moveevent,upevent)
            hObj.source=listen_obj;
            hObj.downeventname=downevent;
            hObj.moveeventname=moveevent;
            hObj.upeventname=upevent;

            hObj.drag_singleton=matlab.graphics.interaction.uiaxes.DragSingleton.getInstance();
        end
    end

    methods
        function enable(hObj)
            hObj.delete_listeners();
            hObj.start_listen=event.listener(hObj.source,hObj.downeventname,@hObj.validate_drag);
            hObj.Enabled=true;
        end

        function disable(hObj)
            hObj.start_listen=[];
            hObj.delete_listeners();
            hObj.Enabled=false;
        end

        function abort(hObj)

            if~isempty(hObj.custom_event_data)&&~isempty(hObj.last_event_data)
                hObj.cancel_drag(hObj.source,hObj.last_event_data,hObj.custom_event_data);
            end
        end
    end

    methods(Access=private)
        function validate_drag(hObj,o,e)
            if(~isprop(o,'SelectionType')||strcmp(o.SelectionType,'normal'))&&hObj.validate(o,e)

                hObj.yyaxis_update(e);

                start_drag(hObj,o,e);
            end
        end








        function yyaxis_update(~,e)
            if~isprop(e,'HitPrimitive')
                return;
            end


            obj=e.HitPrimitive;

            if isempty(obj)||~isvalid(obj)
                return
            end

            ax=ancestor(obj,'axes');
            if(~isscalar(ax)||~isvalid(ax)||strcmpi(ax.BeingDeleted,'on')||(numel(ax.TargetManager.Children)<2))
                return
            end

            ax.processFigureHitObject(obj);
        end

        function start_drag(hObj,o,e)
            hObj.delete_listeners();

            if(~isa(e.Source,'hInteractionSourceObject')&&~isprop(e,'PointInPixels'))...
                ||isprop(e,'Chart')
                e=matlab.graphics.interaction.uiaxes.MouseEventData(o,e);
            end
            customevd=hObj.start(o,e);
            hObj.custom_event_data=customevd;
            hObj.last_event_data=e;
            hObj.drag_singleton.MidDrag=true;
            hObj.move_listen=event.listener(hObj.source,hObj.moveeventname,@(o,evd)hObj.move_drag(o,evd,customevd));
            hObj.stop_listen=event.listener(hObj.source,hObj.upeventname,@(o,evd)hObj.stop_drag(o,evd,customevd));
            hObj.start_listen=[];
            hObj.cancel_listen=event.listener(hObj.source,hObj.downeventname,@(o,evd)hObj.cancel_drag(o,evd,customevd));
        end

        function move_drag(hObj,o,e,customevd)
            if(~isa(e.Source,'hInteractionSourceObject')&&~isprop(e,'PointInPixels'))...
                ||isprop(e,'Chart')
                e=matlab.graphics.interaction.uiaxes.MouseEventData(o,e);
            end
            hObj.last_event_data=e;
            hObj.move(o,e,customevd);
        end

        function stop_drag(hObj,o,e,customevd)
            if(~isa(e.Source,'hInteractionSourceObject')&&~isprop(e,'PointInPixels'))...
                ||isprop(e,'Chart')
                e=matlab.graphics.interaction.uiaxes.MouseEventData(o,e);
            end
            hObj.custom_event_data=[];
            hObj.last_event_data=[];
            hObj.delete_listeners();
            hObj.stop(o,e,customevd);
            hObj.drag_singleton.MidDrag=false;
            hObj.start_listen=event.listener(hObj.source,hObj.downeventname,@hObj.validate_drag);
            notify(hObj.drag_singleton,'DragComplete',e);
        end

        function cancel_drag(hObj,o,e,customevd)
            if(~isa(e.Source,'hInteractionSourceObject')&&~isprop(e,'PointInPixels'))...
                ||isprop(e,'Chart')
                e=matlab.graphics.interaction.uiaxes.MouseEventData(o,e);
            end
            hObj.custom_event_data=[];
            hObj.last_event_data=[];
            hObj.delete_listeners();
            hObj.cancel(o,e,customevd);
            hObj.drag_singleton.MidDrag=false;
            hObj.start_listen=event.listener(hObj.source,hObj.downeventname,@hObj.validate_drag);
            notify(hObj.drag_singleton,'DragComplete',e);
        end

        function delete_listeners(hObj)
            hObj.move_listen=[];
            hObj.stop_listen=[];
            hObj.cancel_listen=[];
        end
    end

    methods(Access=protected)
        function ret=isValid(~,~,~)
            ret=true;
        end
    end
end
