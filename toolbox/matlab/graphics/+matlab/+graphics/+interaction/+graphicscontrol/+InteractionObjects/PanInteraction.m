classdef PanInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase&...
    matlab.graphics.interaction.graphicscontrol.InteractionObjects.DragInteractionBase&...
    matlab.graphics.interaction.graphicscontrol.InteractionObjects.LimitInteractionBase




    properties
fig
        disableHitTestDuringInteraction=true;
    end

    methods
        function this=PanInteraction(hAxes)
            this.Object=hAxes;
            this.fig=ancestor(this.Object,'figure');

            if(this.localShouldUseServerSideInteraction())
                this.Type='serversidepan';
            else
                this.Type='pan';
            end

            this.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Drag;
        end

        function props=getPropertiesToSendToWeb(~)
            props={'DimX','DimY','DimZ','disableHitTestDuringInteraction'};
        end
    end

    methods

        function preresponse(this,~)
            this.captureOldLimits(this.Object);
            matlab.graphics.interaction.internal.toggleAxesLayoutManager(this.fig,this.Object,false);
        end

        function startdata=dragstart(this,eventdata)
            matlab.graphics.interaction.internal.initializeView(this.Object);
            point=[eventdata.figx,eventdata.figy];
            startdata=matlab.graphics.interaction.uiaxes.PanBase.getPanStartdata(this.Object,point);
        end

        function dragprogress(this,eventdata,startdata)
            if~isempty(startdata)
                point=[eventdata.figx,eventdata.figy];
                curr_ray=matlab.graphics.interaction.internal.pan.transformPixelsToPoint(startdata.transform,point);

                norm_limits=matlab.graphics.interaction.internal.pan.panFromPointToPoint3D(startdata.orig_axlim,startdata.orig_ray,curr_ray);

                clamped_limits=matlab.graphics.interaction.internal.constrainNormalizedLimitsToDimensions(norm_limits,this.Dimensions);
                x=clamped_limits(1:2);
                y=clamped_limits(3:4);
                z=clamped_limits(5:6);
                [new_xlim,new_ylim,new_zlim]=matlab.graphics.interaction.internal.UntransformLimits(startdata.dataSpaceCopy,x,y,z);

                matlab.graphics.interaction.validateAndSetLimits(this.Object,new_xlim,new_ylim,new_zlim);


            end
        end

        function dragend(~,~,~)

        end

        function postresponse(this,~)
            this.addToUndoStack(this.Object,'Pan');
            matlab.graphics.interaction.internal.toggleAxesLayoutManager(this.fig,this.Object,true);
            this.generateCode(this.Object);
        end
    end

    methods(Hidden=true)
        function tf=localShouldUseServerSideInteraction(this)
            tf=false;


            linkAxes=getappdata(this.Object,'graphics_linkaxes');
            if(~isempty(linkAxes)&&matlab.graphics.interaction.internal.hasMultiCanvasLinkedAxes(linkAxes.LinkProp.Targets))
                tf=true;
                return;
            end


            if(~isempty(getappdata(this.Object,'ContainsPinnedScribeObject')))
                tf=true;
                return;
            end
        end
    end

end
