classdef GeographicZoomInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase




    properties
Figure
ZoomFactor
OldLimits
    end

    methods
        function obj=GeographicZoomInteraction(gx)
            obj.Type='geoaxesserversidezoom';
            obj.Object=gx;
            obj.Figure=ancestor(obj.Object,'figure');
            obj.ZoomFactor=2^(1/gx.StepsPerZoomLevelScrollWheel);
            obj.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Scroll;
        end

        function preresponse(obj,~)
            gx=obj.Object;
            matlab.graphics.interaction.internal.toggleAxesLayoutManager(obj.Figure,gx,false)


            obj.OldLimits.LatitudeLimits=gx.LatitudeLimits;
            obj.OldLimits.LongitudeLimits=gx.LongitudeLimits;
        end

        function response(obj,eventdata)
            gx=obj.Object;
            ds=gx.ActiveDataSpace;
            point=[eventdata.figx,eventdata.figy];


            intpt=matlab.graphics.interaction.internal.calculateIntersectionPoint(point,gx);
            if any(isnan(intpt))
                return
            end

            if(~isempty(eventdata.additionalData)&&(eventdata.additionalData.verticalScrollCount<0))
                zf=1/obj.ZoomFactor;
            else
                zf=obj.ZoomFactor;
            end

            [new_xlim,new_ylim,new_zlim]=matlab.graphics.interaction.uiaxes.SingleActionZoom.calculateSingleShotZoom(gx,intpt,zf);
            normalized_limits=[new_xlim,new_ylim,new_zlim];
            constrained_limits=matlab.graphics.interaction.internal.constrainNormalizedLimitsToDimensions(normalized_limits,"xy");

            xLimitsWorld=constrained_limits(1:2);
            yLimitsWorld=constrained_limits(3:4);
            xCenterWorld=mean(xLimitsWorld);
            yCenterWorld=mean(yLimitsWorld);
            [xCenterProjected,yCenterProjected]=worldToProjected(ds,xCenterWorld,yCenterWorld);
            if diff(yLimitsWorld)>1
                zoomOut(gx,gx.StepsPerZoomLevelScrollWheel,xCenterProjected,yCenterProjected)
            else
                zoomIn(gx,gx.StepsPerZoomLevelScrollWheel,xCenterProjected,yCenterProjected)
            end

            drawnow limitrate;
        end

        function postresponse(obj,~)

            addToUndoStack(obj)

            gx=obj.Object;
            matlab.graphics.interaction.internal.toggleAxesLayoutManager(obj.Figure,gx,true)


            matlab.graphics.interaction.generateLiveCode(gx,matlab.internal.editor.figure.ActionID.PANZOOM)
        end

        function addToUndoStack(obj)
            if isempty(obj.OldLimits)
                return
            end


            cmd.Name='Zoom';


            gx=obj.Object;
            gxProxy=plotedit({'getProxyValueFromHandle',gx});


            fig=obj.Figure;
            cmd.Function=@changeLimits;
            cmd.Varargin={obj,fig,gxProxy,gx.LatitudeLimits,gx.LongitudeLimits};


            cmd.InverseFunction=@changeLimits;
            cmd.InverseVarargin={obj,fig,gxProxy,...
            obj.OldLimits.LatitudeLimits,obj.OldLimits.LongitudeLimits};



            uiundo(fig,'function',cmd)
        end

        function changeLimits(~,fig,gxProxy,latlim,lonlim)
            gx=plotedit({'getHandleFromProxyValue',fig,gxProxy});

            if(~ishghandle(gx))
                return
            end

            gx.LatitudeLimitsRequest=latlim;
            gx.LongitudeLimitsRequest=lonlim;
        end
    end
end
