classdef PlanePan<matlab.graphics.interaction.uiaxes.PanBase




    methods
        function hObj=PlanePan(ax,obj,down,move,up)
            hObj=hObj@matlab.graphics.interaction.uiaxes.PanBase(ax,obj,down,move,up);
        end
    end

    methods(Access=protected)
        function normal=addeventdata(hObj,~)
            normal=hObj.addplanedata();
        end

        function norm_limits=performpan(hObj,~,c,curr_ray)
            norm_limits=hObj.planepan(c.orig_axlim,c.addeddata,c.orig_ray,curr_ray);
        end

        function i=getdduxinteractionname(~)
            i='dragpan';
        end
    end

    methods(Access=private)
        function normal=addplanedata(hObj)
            switch(hObj.Dimensions)
            case 'xy'
                normal=[0,0,1];
            case 'yz'
                normal=[1,0,0];
            case 'xz'
                normal=[0,1,0];
            end
        end

        function new_limits=planepan(~,orig_limits,normal,orig_ray,curr_ray)
            import matlab.graphics.interaction.internal.pan.findProjectedVectorOnPlane
            import matlab.graphics.interaction.internal.pan.calculatePannedLimits
            delta=findProjectedVectorOnPlane(orig_ray,curr_ray,normal);
            new_limits=calculatePannedLimits(orig_limits,delta);
        end
    end
end
