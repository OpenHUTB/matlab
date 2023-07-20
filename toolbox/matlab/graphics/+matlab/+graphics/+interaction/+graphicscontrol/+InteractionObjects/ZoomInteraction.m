classdef ZoomInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase&...
    matlab.graphics.interaction.graphicscontrol.InteractionObjects.LimitInteractionBase



    properties
zoomFactor
    end
    methods
        function this=ZoomInteraction(hAxes)
            this.zoomFactor=1.1;
            this.Object=hAxes;

            if(this.localShouldUseServerSideInteraction())
                this.Type='serversidezoom';
            else
                this.Type='zoom';
            end

            this.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Scroll;
        end

        function props=getPropertiesToSendToWeb(~)
            props={'DimX','DimY','DimZ'};
        end

        function preresponse(this,~)
            this.captureOldLimits(this.Object);
        end

        function response(this,eventdata)
            matlab.graphics.interaction.internal.initializeView(this.Object);
            point=[eventdata.figx,eventdata.figy];


            intpt=matlab.graphics.interaction.internal.calculateIntersectionPoint(point,this.Object);
            if any(isnan(intpt))
                return
            end


            if(~isempty(eventdata.additionalData)&&(eventdata.additionalData.verticalScrollCount<0))
                zf=1/this.zoomFactor;
            else
                zf=this.zoomFactor;
            end


            [new_xlim,new_ylim,new_zlim]=matlab.graphics.interaction.uiaxes.SingleActionZoom.calculateSingleShotZoom(this.Object,intpt,zf);
            normalized_limits=[new_xlim,new_ylim,new_zlim];
            constrained_limits=matlab.graphics.interaction.internal.constrainNormalizedLimitsToDimensions(normalized_limits,"xy");

            [x,y,z]=matlab.graphics.interaction.internal.UntransformLimits(this.Object.ActiveDataSpace,constrained_limits(1:2),constrained_limits(3:4),constrained_limits(5:6));
            bounds=matlab.graphics.interaction.internal.getBounds(this.Object,true);
            [new_xlim,new_ylim,new_zlim]=matlab.graphics.interaction.internal.boundLimitsAllAxes([x,y,z],bounds,false);

            matlab.graphics.interaction.validateAndSetLimits(this.Object,new_xlim,new_ylim);
        end

        function postresponse(this,~)
            this.addToUndoStack(this.Object,'Zoom');
            this.generateCode(this.Object);
        end
    end

    methods(Hidden=true)
        function tf=localShouldUseServerSideInteraction(this)
            tf=false;


            linkAxes=getappdata(this.Object,'graphics_linkaxes');
            is2DAxes=GetLayoutInformation(this.Object).is2D;
            if(~isempty(linkAxes)&&matlab.graphics.interaction.internal.hasMultiCanvasLinkedAxes(linkAxes.LinkProp.Targets))&&...
                (is2DAxes&&all(get(this.Object,'view')==[0,90]))
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
