classdef GeographicPanInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase&...
    matlab.graphics.interaction.graphicscontrol.InteractionObjects.DragInteractionBase




    properties
Figure
OldLimits
    end

    methods
        function obj=GeographicPanInteraction(gx)
            obj.Type='geoaxesserversidepan';
            obj.Object=gx;
            obj.Figure=ancestor(obj.Object,'figure');
            obj.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Drag;
        end

        function preresponse(obj,~)
            gx=obj.Object;
            matlab.graphics.interaction.internal.toggleAxesLayoutManager(obj.Figure,gx,false)


            obj.OldLimits.LatitudeLimits=gx.LatitudeLimits;
            obj.OldLimits.LongitudeLimits=gx.LongitudeLimits;
        end

        function startdata=dragstart(obj,eventdata)
            gx=obj.Object;
            point=[eventdata.figx,eventdata.figy];
            startdata=matlab.graphics.interaction.uiaxes.PanBase.getPanStartdata(gx,point);
        end

        function dragprogress(obj,eventdata,startdata)
            if~isempty(startdata)
                gx=obj.Object;
                point=[eventdata.figx,eventdata.figy];
                curr_ray=matlab.graphics.interaction.internal.pan.transformPixelsToPoint(startdata.transform,point);

                limits=matlab.graphics.interaction.internal.pan.panFromPointToPoint3D(startdata.orig_axlim,startdata.orig_ray,curr_ray);

                xLimitsWorld=limits(1:2);
                yLimitsWorld=limits(3:4);
                xCenterWorld=mean(xLimitsWorld);
                yCenterWorld=mean(yLimitsWorld);
                [xCenterProjected,yCenterProjected]=worldToProjected(startdata.dataSpaceCopy,xCenterWorld,yCenterWorld);
                recenter(gx,xCenterProjected,yCenterProjected)
                drawnow limitrate;
            end
        end

        function dragend(~,~,~)

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


            cmd.Name='Pan';


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
