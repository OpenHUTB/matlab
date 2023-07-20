classdef DraggbleDatatipInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase&...
    matlab.graphics.interaction.graphicscontrol.InteractionObjects.DragInteractionBase




    properties
Canvas
Figure
        PlotEditModeActive(1,1)logical=false
    end

    methods
        function this=DraggbleDatatipInteraction(object,canvas)
            this.Type='draggabledatatip';
            this.ID=uint64(0);
            this.ObjectPeerID=uint64(0);
            this.Object=object;
            this.Canvas=canvas;
            this.Figure=ancestor(this.Object,'figure','node');
            this.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Drag;
        end

        function startdata=dragstart(this,~)
            startdata=[];
            this.PlotEditModeActive=isactiveuimode(this.Figure,'Standard.EditPlot');
        end

        function dragprogress(this,eventData,~)



            if this.PlotEditModeActive
                return
            end




            hTip=ancestor(this.Object,'matlab.graphics.shape.internal.PointDataTip','node');

            hTip.Cursor.moveTo([eventData.figx,eventData.figy]);
        end

        function dragend(this,~,~)

            matlab.graphics.datatip.internal.generateDataTipLiveCode(this.Object,matlab.internal.editor.figure.ActionID.DATATIP_EDITED);
        end
    end
end
