classdef DataTipClickInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.DataTipBaseInteraction




    methods
        function this=DataTipClickInteraction(canvas,ax,dataTipInteraction)
            this@matlab.graphics.interaction.graphicscontrol.InteractionObjects.DataTipBaseInteraction(canvas,ax,dataTipInteraction);
            this.Action=[matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Click];
            dataTipInteraction.enable();
        end

        function handleEvent(this,~,eventData)
            this.DataTipInteraction.ClickToShowDatatip([],eventData);
        end
    end
end
