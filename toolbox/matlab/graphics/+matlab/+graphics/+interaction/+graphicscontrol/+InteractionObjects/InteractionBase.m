classdef InteractionBase<handle&matlab.mixin.Heterogeneous




    properties
Type
ID
Object
ObjectPeerID
        MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.None;
Actions
ObjectBeingDestroyedListener


        PickStrategy=0;
        EventsToBeCoalesced=["hover","dragprogress","pinchprogress","scroll"];
    end

    properties(Access=private)
Control_Storage
ControlListener_PreResponseListener
ControlListener_ResponseListener
ControlListener_PostResponseListener
ControlListener_EnterExitListner
    end

    properties(Dependent)
Control
        Action(1,1)
    end

    methods
        function this=InteractionBase()
            this.Type='base';
            this.Control=[];
            this.ID=uint64(0);
            this.ObjectPeerID=uint64(0);
            this.ObjectBeingDestroyedListener=[];
        end

        function props=getPropertiesToSendToWeb(~)
            props={};
        end

        function set.Control(obj,val)
            if~isempty(val)
                if~isempty(obj.ControlListener_PreResponseListener)
                    delete(obj.ControlListener_PreResponseListener);
                end
                if~isempty(obj.ControlListener_ResponseListener)
                    delete(obj.ControlListener_ResponseListener);
                end
                if~isempty(obj.ControlListener_PostResponseListener)
                    delete(obj.ControlListener_PostResponseListener);
                end
                if~isempty(obj.ControlListener_EnterExitListner)
                    delete(obj.ControlListener_EnterExitListner);
                end
                obj.Control_Storage=val;
                obj.ControlListener_PreResponseListener=listener(val,'PreResponse',@(o,e)preresponseevent(obj,e));
                obj.ControlListener_ResponseListener=listener(val,'Action',@(o,e)responseevent(obj,e));
                obj.ControlListener_PostResponseListener=listener(val,'PostResponse',@(o,e)postresponseevent(obj,e));
                obj.ControlListener_EnterExitListner=listener(val,'EnterExit',@(o,e)enterexitevent(obj,e));
            end
        end

        function set.Action(obj,val)
            obj.Actions=val.getActions;
        end

        function val=get.Control(obj)
            val=obj.Control_Storage;
        end


        function set.Object(obj,val)
            obj.Object=val;

            obj.updatePickStrategy(val);
        end

        function val=get.EventsToBeCoalesced(obj)
            val=obj.EventsToBeCoalesced;
        end

        function enterexitevent(obj,eventdata)%#ok<INUSD>

        end

        function preresponse(obj,eventdata)%#ok<INUSD>

        end

        function postresponse(obj,eventdata)%#ok<INUSD>

        end
    end

    methods(Sealed)
        function responseevent(obj,e)











            if(any(lower(string(obj.Actions))==lower(e.name))&&...
                obj.ID==e.interactionID)
                response(obj,e);
                can=ancestor(obj.Object,'matlab.graphics.primitive.canvas.Canvas','node');
                if~isempty(can)&&isprop(can,'InteractionsManager')&&any(ismember(obj.EventsToBeCoalesced,lower(e.name)))


                    can.InteractionsManager.sendMessageToClient(obj.ID,'flush',e.name);
                end
            end
        end

        function preresponseevent(obj,e)
            if(any(lower(string(obj.Actions))==lower(e.Action))&&...
                obj.ID==e.InteractionID)
                preresponse(obj,e);
            end
        end

        function postresponseevent(obj,e)
            if(any(lower(string(obj.Actions))==lower(e.Action))&&...
                obj.ID==e.InteractionID)
                postresponse(obj,e);
            end
        end

        function updatePickStrategy(obj,hObj)

            if isa(hObj,'matlab.graphics.axis.AbstractAxes')
                if~hObj.Visible
                    obj.PickStrategy=1;
                end
            end
        end
    end

    methods(Abstract)
        response(obj,eventdata)
    end
end
