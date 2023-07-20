classdef LimitZoom3DInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase&...
    matlab.graphics.interaction.graphicscontrol.InteractionObjects.DragInteractionBase&...
    matlab.graphics.interaction.graphicscontrol.InteractionObjects.LimitInteractionBase




    properties
ax
fig
        disableHitTestDuringInteraction=true;
    end

    methods
        function this=LimitZoom3DInteraction(~,haxes)
            this.Type='zoom3d';
            this.ax=haxes;

            this.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Drag;
        end

        function props=getPropertiesToSendToWeb(~)
            props={'disableHitTestDuringInteraction'};
        end
    end

    methods

        function preresponse(this,~)
            this.captureOldLimits(this.ax);
            this.fig=ancestor(this.ax,'figure');
            if~isempty(this.fig)&&isvalid(this.fig)
                matlab.graphics.interaction.internal.toggleAxesLayoutManager(this.fig,this.ax,false);
            end
        end

        function startdata=dragstart(this,eventdata)
            matlab.graphics.interaction.internal.initializeView(this.ax);

            pixelpoint=[eventdata.x,eventdata.y];
            origlimits=eventdata.Source.getCurrentLimits();
            datapoint=mean(reshape(origlimits,2,3));
            startdata=matlab.graphics.interaction.uiaxes.LimitZoom3D.startImpl(this.ax,pixelpoint,datapoint);
        end

        function dragprogress(this,eventdata,startdata)
            if~isempty(startdata)
                pixelpoint=[eventdata.x,eventdata.y];
                [new_xlim,new_ylim,new_zlim]=matlab.graphics.interaction.uiaxes.LimitZoom3D.moveImpl(300,pixelpoint,startdata);
                matlab.graphics.interaction.validateAndSetLimits(this.ax,new_xlim,new_ylim,new_zlim);
            end
        end

        function dragend(~,~,~)

        end

        function postresponse(this,~)
            this.addToUndoStack(this.ax,'Zoom');
            if~isempty(this.fig)&&isvalid(this.fig)
                matlab.graphics.interaction.internal.toggleAxesLayoutManager(this.fig,this.ax,true);
            end
            this.generateCode(this.ax);
        end

    end
end
