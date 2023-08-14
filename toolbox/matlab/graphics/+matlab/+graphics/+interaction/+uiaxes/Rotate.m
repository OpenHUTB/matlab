classdef Rotate<matlab.graphics.interaction.uiaxes.Drag&matlab.graphics.interaction.uiaxes.InteractionBase



    properties
        Gain=1;
        DoNotChangeLimitsWhileRotating=false;
    end

    properties(Access=private,Hidden)
        startPointPixels=[0,0]
        zoomMidDragListener;
        resetOrigLimitsAndPixelPointFlag=false;
    end

    methods
        function hObj=Rotate(ax,obj,down,move,up)
            hObj=hObj@matlab.graphics.interaction.uiaxes.InteractionBase;
            hObj=hObj@matlab.graphics.interaction.uiaxes.Drag(obj,down,move,up);
            hObj.Axes=ax;
            hObj.Figure=ancestor(ax,'figure');
        end
    end

    methods(Access=protected)
        function ret=validate(hObj,o,e)
            isvalid=hObj.strategy.isValidMouseEvent(hObj,o,e);
            ishit=hObj.strategy.isObjectHit(hObj,o,e);
            ret=isvalid&&ishit;
        end

        function custom=start(hObj,~,e)
            if~isempty(hObj.Figure)&&isvalid(hObj.Figure)
                matlab.graphics.interaction.internal.toggleAxesLayoutManager(hObj.Figure,hObj.Axes,false);
            end

            pboxsize=hObj.Axes.GetLayoutInformation.PlotBox(3:4);
            custom=matlab.graphics.interaction.uiaxes.Rotate.startImpl(hObj.Axes.View,pboxsize,1,e.PointInPixels);

            if hObj.DoNotChangeLimitsWhileRotating
                custom.orig_xlimmode='manual';
                custom.orig_ylimmode='manual';
                custom.orig_zlimmode='manual';
                if strcmp(hObj.Axes.XLimMode,'auto')
                    custom.orig_xlimmode='auto';
                    hObj.Axes.XLimMode='manual';
                end
                if strcmp(hObj.Axes.YLimMode,'auto')
                    custom.orig_ylimmode='auto';
                    hObj.Axes.YLimMode='manual';
                end
                if strcmp(hObj.Axes.ZLimMode,'auto')
                    custom.orig_zlimmode='auto';
                    hObj.Axes.ZLimMode='manual';
                end
            end
        end

        function move(hObj,~,e,c)
            new_view=matlab.graphics.interaction.uiaxes.Rotate.moveImpl(e.PointInPixels,c);
            hObj.strategy.setView(hObj.Axes,new_view);
        end

        function stop(hObj,~,~,c)
            hObj.stopOrCancel(c);
            matlab.graphics.interaction.internal.setInteractiveDDUXData(hObj.Axes,'rotate','default');
        end

        function cancel(hObj,~,~,c)
            hObj.stopOrCancel(c);
        end
    end

    methods(Static)
        function s=startImpl(view,size,gain,point)
            s.startpointpixels=point;


            s.xgain=gain*0.3*(434/size(1));
            s.ygain=gain*0.3*(343/size(2));

            s.orig_view=view;
        end

        function new_view=moveImpl(point,c)
            pixeldiff=point-c.startpointpixels;
            new_view=calculateView(c.orig_view,pixeldiff,c.xgain,c.ygain);

            function new_view=calculateView(curr_view,pixeldiff,xg,yg)
                delta_az=xg*(-pixeldiff(1));
                delta_el=yg*(-pixeldiff(2));
                new_view(1)=curr_view(1)+delta_az;
                new_view(2)=min(max(curr_view(2)+2*delta_el,-90),90);
                if abs(new_view(2))>90

                    new_view(1)=rem(rem(azel(1)+180,360)+180,360)-180;

                    new_view(2)=sign(azel(2))*(180-abs(azel(2)));
                end
            end
        end
    end

    methods(Access=private)
        function stopOrCancel(hObj,c)
            if~isempty(hObj.Figure)&&isvalid(hObj.Figure)
                matlab.graphics.interaction.internal.toggleAxesLayoutManager(hObj.Figure,hObj.Axes,true);
            end

            if hObj.DoNotChangeLimitsWhileRotating
                if strcmp(c.orig_xlimmode,'auto')
                    hObj.Axes.XLimMode='auto';
                end
                if strcmp(c.orig_ylimmode,'auto')
                    hObj.Axes.YLimMode='auto';
                end
                if strcmp(c.orig_zlimmode,'auto')
                    hObj.Axes.ZLimMode='auto';
                end
            end
        end
    end
end
