classdef GenericControl<matlab.graphics.interaction.graphicscontrol.ControlBase




    events
Action
EnterExit
PreResponse
PostResponse
    end

    methods
        function this=GenericControl()
            this=this@matlab.graphics.interaction.graphicscontrol.ControlBase();
            this.Type='generic';
        end

        function tf=needsSetup(obj)
            tf=false;
        end

        function response=process(this,message)
            response=struct;
            switch message.name
            case 'action'
                edata=matlab.graphics.interaction.graphicscontrol.ActionEventData...
                (message.actionData.figx,message.actionData.figy,...
                message.actionData.x,message.actionData.y,...
                message.actionData.name,...
                message.actionData.interactionID,...
                message.actionData.hitObjectIds,...
                message.additionalData);
                notify(this,'Action',edata);
            case 'enterexit'
                edata=matlab.graphics.interaction.graphicscontrol.EnterExitEventData...
                (message.actionData.name);
                notify(this,'EnterExit',edata);
            case 'preresponse'
                edata=matlab.graphics.interaction.graphicscontrol.PreAndPostResponseEventData...
                (message.interactionID,message.actionData.name);
                notify(this,'PreResponse',edata);
            case 'postresponse'
                edata=matlab.graphics.interaction.graphicscontrol.PreAndPostResponseEventData...
                (message.interactionID,message.actionData.name);
                notify(this,'PostResponse',edata);
            otherwise

            end
        end
    end
end
