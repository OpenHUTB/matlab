classdef DataTipDisableEnableInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.DataTipBaseInteraction




    methods
        function this=DataTipDisableEnableInteraction(canvas,ax,dataTipInteraction)
            this@matlab.graphics.interaction.graphicscontrol.InteractionObjects.DataTipBaseInteraction(canvas,ax,dataTipInteraction);
            this.Actions=[matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.DragStart
            matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.DragEnd
            matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.Scroll];
        end

        function handleEvent(this,name,eventData)
            switch name
            case 'dragstart'
                for i=1:numel(this.DataTipInteraction)
                    this.DataTipInteraction(i).disableLinger([],eventData);
                end
            case 'dragend'
                for i=1:numel(this.DataTipInteraction)
                    this.DataTipInteraction(i).enableLinger([],eventData);
                end
            case 'scroll'
                for i=1:numel(this.DataTipInteraction)
                    this.DataTipInteraction(i).disableOnScroll([],eventData);
                end
            end
        end
    end
end
