classdef UnconstrainedPan<matlab.graphics.interaction.uiaxes.PanBase



    methods
        function hObj=UnconstrainedPan(ax,obj,down,move,up)
            hObj=hObj@matlab.graphics.interaction.uiaxes.PanBase(ax,obj,down,move,up);
        end
    end

    methods(Access=protected)
        function c=addeventdata(~,~)
            c=[];
        end

        function norm_limits=performpan(~,~,c,curr_ray)
            norm_limits=matlab.graphics.interaction.internal.pan.panFromPointToPoint3D(c.orig_axlim,c.orig_ray,curr_ray);
        end

        function i=getdduxinteractionname(~)
            i='dragpan';
        end
    end
end
