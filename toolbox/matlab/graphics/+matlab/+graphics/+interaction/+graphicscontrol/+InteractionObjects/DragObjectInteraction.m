classdef DragObjectInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase&...
    matlab.graphics.interaction.graphicscontrol.InteractionObjects.DragInteractionBase


    methods
        function this=DragObjectInteraction(objectToMove)
            this.Object=objectToMove;
            this.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Drag;
        end
    end

    methods
        function startdata=dragstart(this,eventdata)
            fig=ancestor(this.Object,'figure');
            startdata.container=ancestor(this.Object,'matlab.ui.internal.mixin.CanvasHostMixin');
            objectPos=hgconvertunits(fig,[this.Object.Position(1:2),0,0],this.Object.Units,'pixels',startdata.container);



            offsetX=eventdata.figx-objectPos(1);
            offsetY=eventdata.figy-objectPos(2);
            startdata.offset=[offsetX,offsetY];
            startdata.figure=fig;
        end

        function dragprogress(this,eventdata,startdata)
            pos=[eventdata.figx-startdata.offset(1),eventdata.figy-startdata.offset(2)];
            pos=hgconvertunits(startdata.figure,[pos,0,0],'pixels',this.Object.Units,startdata.container);
            this.Object.Position(1:2)=pos(1:2);
        end

        function postresponse(this,~)

            matlab.graphics.interaction.generateLiveCode(this.Object,matlab.internal.editor.figure.ActionID.OBJECT_MOVED);
        end

        function dragend(this,~,~)
        end
    end
end