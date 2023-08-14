classdef MouseController<handle













    properties(SetAccess=private,GetAccess=?tGlobeMouseController,Hidden)
Controller
MainListener
LastListenerEnabled
        EnabledListenerCount=struct
        InternalListeners=event.listener.empty
    end

    events
LeftMouseClick
LeftMouseUp
LeftMouseDown
MouseMove
RightMouseClick
RightMouseUp
RightMouseDown
MouseWheel
MouseClickPlay
MouseClickTimeline
    end

    methods(Access=public)
        function listener=addlistener(obj,type,fcn)
            listener=addlistener@handle(obj,type,fcn);
            obj.InternalListeners(end+1)=addlistener(listener,'Enabled','PreSet',...
            @(src,data)onEnableDisableListener_Pre(obj,data));
            obj.InternalListeners(end+1)=addlistener(listener,'Enabled','PostSet',...
            @(~,data)onEnableDisableListener_Post(obj,data));
            obj.InternalListeners(end+1)=addlistener(listener,'ObjectBeingDestroyed',...
            @(~,data)onDestroyListener(obj,data));
            if(~isfield(obj.EnabledListenerCount,type))
                obj.EnabledListenerCount.(type)=0;
            end
            updateEnabledListenerCount(obj,type,true);
        end
    end

    methods
        function obj=MouseController(controller)
            obj.Controller=controller;


            obj.MainListener=event.listener(controller,...
            'MouseEvent',@(src,data)processMouseEvent(obj,data));
        end

        function delete(obj)
            numListeners=numel(obj.InternalListeners);
            for k=1:numListeners
                if(isvalid(obj.InternalListeners(k)))
                    delete(obj.InternalListeners(k));
                end
            end
        end
    end

    methods(Access=private)
        function onEnableDisableListener_Pre(obj,data)


            obj.LastListenerEnabled=data.AffectedObject.Enabled;
        end

        function onEnableDisableListener_Post(obj,data)



            if obj.LastListenerEnabled~=data.AffectedObject.Enabled
                updateEnabledListenerCount(obj,data.AffectedObject.EventName,data.AffectedObject.Enabled);
            end
        end

        function onDestroyListener(obj,data)


            if data.Source.Enabled
                updateEnabledListenerCount(obj,data.Source.EventName,false);
            end
        end

        function updateEnabledListenerCount(obj,type,enabled)

            if~isvalid(obj.Controller)
                return
            end


            initialCount=obj.EnabledListenerCount.(type);
            if(enabled)
                obj.EnabledListenerCount.(type)=obj.EnabledListenerCount.(type)+1;
            else
                obj.EnabledListenerCount.(type)=obj.EnabledListenerCount.(type)-1;
            end
            currentCount=obj.EnabledListenerCount.(type);



            if(initialCount==0&&currentCount==1)


                obj.Controller.visualRequest('setMouseListener',...
                struct('On',true,...
                'Type',type,...
                'EnableWindowLaunch',true,...
                'Animation','none'));
            elseif(currentCount==0)


                obj.Controller.visualRequest('setMouseListener',...
                struct('On',false,...
                'Type',type,...
                'EnableWindowLaunch',true,...
                'Animation','none'));
            end
        end

        function processMouseEvent(obj,data)


            notify(obj,data.MouseData.Type,globe.internal.MouseEventData(data));
        end
    end
end