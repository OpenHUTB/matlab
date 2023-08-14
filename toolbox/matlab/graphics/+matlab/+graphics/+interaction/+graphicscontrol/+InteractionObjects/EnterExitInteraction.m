classdef EnterExitInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase




    properties
Canvas
    end

    methods
        function this=EnterExitInteraction
            this.Type='enterexit';
            this.ID=uint64(0);
            this.ObjectPeerID=uint64(0);

            this.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Exit;
        end

        function enable(obj,canvas)
            obj.Canvas=canvas;
        end

        function response(obj,eventdata)%#ok<INUSD>
        end

        function enterexitevent(this,actionData)
            switch(actionData.enterexit)
            case 'Entered'

            case{'ExitedObject','ExitedCanvas'}
                eventData=matlab.graphics.interaction.graphicscontrol.ExitInteractionEventData(actionData.enterexit);
                this.Canvas.notify('ButtonExited',eventData);

            end
        end
    end
end
