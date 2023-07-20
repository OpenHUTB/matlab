classdef DataTipHoverLingerInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.DataTipBaseInteraction




    methods
        function this=DataTipHoverLingerInteraction(canvas,ax,dataTipInteraction)
            this@matlab.graphics.interaction.graphicscontrol.InteractionObjects.DataTipBaseInteraction(canvas,ax,dataTipInteraction);
            this.Action=[matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Hover];
            dataTipInteraction.isWeb=true;
            dataTipInteraction.enable();
        end

        function handleEvent(this,~,eventData)
            this.DataTipInteraction.motionCallback([],eventData);
            this.DataTipInteraction.linger.motionCallback(this.Canvas,eventData);
        end
    end
end
