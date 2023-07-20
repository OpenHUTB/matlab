classdef DataTipHoverInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.DataTipBaseInteraction




    methods
        function this=DataTipHoverInteraction(canvas,ax,dataTipInteraction)
            this@matlab.graphics.interaction.graphicscontrol.InteractionObjects.DataTipBaseInteraction(canvas,ax,dataTipInteraction);
            this.Action=[matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Hover];
            dataTipInteraction.enable();
        end

        function handleEvent(this,~,eventData)
            if isa(eventData.HitObject,'matlab.graphics.chart.primitive.Line')||...
                isa(eventData.HitObject,'matlab.graphics.primitive.Line')

                return
            end
            this.DataTipInteraction.linger.motionCallback(this.Canvas,eventData);
            this.DataTipInteraction.motionCallback([],eventData);
        end
    end
end


