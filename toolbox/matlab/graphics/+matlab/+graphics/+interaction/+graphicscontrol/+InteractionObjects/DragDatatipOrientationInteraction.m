classdef DragDatatipOrientationInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase&...
    matlab.graphics.interaction.graphicscontrol.InteractionObjects.DragInteractionBase



    properties
Figure
        PlotEditModeActive(1,1)logical=false
    end

    methods
        function this=DragDatatipOrientationInteraction(object)
            this.Type='dragdatatiporientation';
            this.Object=object;
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

            evd.Point=[eventData.figx,eventData.figy];
            evd.Source=this.Figure;
            matlab.graphics.shape.internal.PointDataTipController.localTextMotion([],evd,this.Object);
        end

        function dragend(this,~,~)
            matlab.graphics.datatip.internal.generateDataTipLiveCode(this.Object,matlab.internal.editor.figure.ActionID.DATATIP_EDITED);
        end
    end
end