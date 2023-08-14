classdef ROIZoomAffordance<matlab.graphics.interaction.uiaxes.Drag&...
    matlab.graphics.interaction.uiaxes.InteractionBase&...
    matlab.graphics.interaction.uiaxes.LimitInteractionBase


    properties
Container
        WhiskerLength=8;
    end

    properties(Dependent)
Color
    end

    properties(Access=?tmatlab_graphics_interaction_uiaxes_ROIZoomAffordance)
line
sv
    end

    methods
        function hObj=ROIZoomAffordance(ax,fig,down,move,up)
            container=ancestor(ax,'matlab.ui.internal.mixin.CanvasHostMixin');
            hObj=hObj@matlab.graphics.interaction.uiaxes.Drag(fig,down,move,up);

            hObj.sv=hObj.getAnnotationPane(ax);

            hObj.Axes=ax;
            hObj.Figure=fig;
            hObj.Container=container;
            hObj.line=hObj.createLine();
        end

        function set.Color(hObj,val)
            hObj.line.Color=val;
        end

        function val=get.Color(hObj)
            val=hObj.line.Color;
        end
    end

    methods(Access=protected)
        function ret=validate(hObj,o,e)
            isvalid=hObj.strategy.isValidMouseEvent(hObj,o,e);
            ishit=hObj.strategy.isObjectHit(hObj,o,e);
            is2d=is2D(hObj.Axes);
            ret=isvalid&&ishit&&is2d;
        end

        function c=start(hObj,~,e)
            c.conpos=getpixelposition(hObj.Container,true);
            c.startptpixels=e.PointInPixels;
            c.startpt=hObj.getNormalizedPt(e.PointInPixels,c.conpos);

            hObj.line.Parent=hObj.sv;
        end

        function move(hObj,~,e,c)
            currpt=hObj.getNormalizedPt(e.PointInPixels,c.conpos);

            dist_in_x=abs(c.startptpixels(1)-e.PointInPixels(1));
            dist_in_y=abs(c.startptpixels(2)-e.PointInPixels(2));
            x_not_far_enough=dist_in_x<15;
            y_not_far_enough=dist_in_y<15;

            if(hObj.Dimensions=="xyz")

                if(x_not_far_enough)
                    constraint="y";

                elseif(y_not_far_enough)
                    constraint="x";
                else
                    constraint="xyz";
                end
            else
                constraint=hObj.Dimensions;
            end


            hObj.updateLineData(constraint,c.startpt,currpt,c.startptpixels,c.conpos);
        end

        function stop(hObj,~,~,~)
            hObj.clearLineData();
        end

        function cancel(hObj,~,~,~)
            hObj.clearLineData();
        end
    end

    methods(Access=private)
        function clearLineData(hObj)
            hObj.line.XData=[];
            hObj.line.YData=[];
        end

        function updateLineData(hObj,constraint,startpt,currpt,startptpixels,conpos)
            [x_whisker,y_whisker]=hObj.calculateWhiskerData(startptpixels,conpos);
            [x,y]=matlab.graphics.interaction.internal.zoom.calculateZoomLineData(startpt(1),currpt(1),startpt(2),currpt(2),x_whisker,y_whisker,constraint);
            hObj.line.XData=x;
            hObj.line.YData=y;
        end

        function[x_end,y_end]=calculateWhiskerData(hObj,startptpixels,conpos)
            xy_end_pixels=startptpixels+[-1;1].*hObj.WhiskerLength;
            xy=hObj.getNormalizedPt(xy_end_pixels(1,:),conpos);
            x_end(1)=xy(1);
            y_end(1)=xy(2);
            xy2=hObj.getNormalizedPt(xy_end_pixels(2,:),conpos);
            x_end(2)=xy2(1);
            y_end(2)=xy2(2);
        end

        function line=createLine(~)
            line=matlab.graphics.primitive.Line;
            line.HandleVisibility='off';
            line.HitTest='off';
            line.Color=[0.65,0.65,0.65];
            line.AlignVertexCenters='on';
            line.Serializable='off';
            line.PickableParts='none';
            line.LineWidth=1;
            line.XData=[];
            line.YData=[];
        end

        function normpt=getNormalizedPt(hObj,pt,conpos)
            if isa(hObj.Container,'matlab.ui.Figure')
                normpt(1)=pt(1)/conpos(3);
                normpt(2)=pt(2)/conpos(4);
            else
                normpt(1)=(pt(1)-conpos(1))/conpos(3);
                normpt(2)=(pt(2)-conpos(2))/conpos(4);
            end
        end

        function ap=getAnnotationPane(~,ax)
            canvas=ancestor(ax,'matlab.graphics.primitive.canvas.Canvas','node');
            ap=matlab.graphics.annotation.internal.getDefaultCamera(canvas.NodeParent,'overlay','-peek');



            if isempty(ap)
                ap=matlab.graphics.shape.internal.AnnotationPane('Parent',canvas.NodeParent,'Serializable','off');
            end
        end
    end
end

