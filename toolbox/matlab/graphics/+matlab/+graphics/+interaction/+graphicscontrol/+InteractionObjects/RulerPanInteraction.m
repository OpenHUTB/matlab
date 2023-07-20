classdef RulerPanInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase&...
    matlab.graphics.interaction.graphicscontrol.InteractionObjects.DragInteractionBase&...
    matlab.graphics.interaction.graphicscontrol.InteractionObjects.LimitInteractionBase




    properties
Canvas
ax
fig
Axis
    end

    methods
        function this=RulerPanInteraction(canvas,haxes)
            this.Type='rulerpan';
            this.Canvas=canvas;
            this.ax=haxes;

            this.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Drag;
        end
    end

    methods

        function preresponse(this,~)
            this.captureOldLimits(this.ax);
            this.fig=ancestor(this.ax,'figure');
            matlab.graphics.interaction.internal.toggleAxesLayoutManager(this.fig,this.ax,false);
        end

        function startdata=dragstart(this,eventdata)
            matlab.graphics.interaction.internal.initializeView(this.ax);

            point=[eventdata.figx,eventdata.figy];

            startdata.startPointPixels=point;

            startdata.dataSpaceCopy=matlab.graphics.interaction.internal.copyDataSpace(this.ax.ActiveDataSpace);
            transform=matlab.graphics.interaction.internal.pan.getMVP(this.ax);
            orig_ray=matlab.graphics.interaction.internal.pan.transformPixelsToPoint(transform,point);

            startdata.transform=transform;
            startdata.orig_ray=orig_ray;

            [ruler_num,plane_num]=matlab.graphics.interaction.uiaxes.AxisPan.createAxisData(this.Axis,point,transform,orig_ray);

            startdata.rulerNum=ruler_num;
            startdata.planeNum=plane_num;
        end

        function dragprogress(this,eventdata,startdata)
            if~isempty(startdata)
                point=[eventdata.figx,eventdata.figy];
            end

            curr_ray=matlab.graphics.interaction.internal.pan.transformPixelsToPoint(startdata.transform,point);

            orig_limits=[0,1,0,1,0,1];

            new_limits=matlab.graphics.interaction.uiaxes.AxisPan.axisPan(startdata.rulerNum,startdata.planeNum,orig_limits,startdata.orig_ray,curr_ray);
            [new_xlim,new_ylim,new_zlim]=matlab.graphics.interaction.internal.UntransformLimits(startdata.dataSpaceCopy,new_limits(1:2),new_limits(3:4),new_limits(5:6));
            matlab.graphics.interaction.validateAndSetLimits(this.ax,new_xlim,new_ylim,new_zlim);
        end

        function dragend(~,~,~)
        end

        function postresponse(this,~)
            this.addToUndoStack(this.ax,'Pan');
            matlab.graphics.interaction.internal.toggleAxesLayoutManager(this.fig,this.ax,true);
            this.generateCode(this.ax);
        end

    end
end
