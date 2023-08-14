classdef AxisPan<matlab.graphics.interaction.uiaxes.PanBase




    methods
        function hObj=AxisPan(ax,obj,down,move,up)
            hObj=hObj@matlab.graphics.interaction.uiaxes.PanBase(ax,obj,down,move,up);
        end
    end

    methods(Access=protected)
        function addeddata=addeventdata(hObj,c)
            [ruler_num,plane_num]=hObj.addaxisdata(c.Point,c.transform,c.orig_ray);
            addeddata.ruler_num=ruler_num;
            addeddata.plane_num=plane_num;
        end

        function norm_limits=performpan(hObj,~,c,curr_ray)
            norm_limits=hObj.axispan(c.addeddata.ruler_num,c.addeddata.plane_num,c.orig_axlim,c.orig_ray,curr_ray);
        end

        function dim=getDimension(hObj)
            dim=hObj.Dimensions;
        end

        function i=getdduxinteractionname(~)
            i='dragpan';
        end
    end

    methods(Access=private)
        function[ruler_num,plane_num]=addaxisdata(hObj,point,transform,orig_ray)
            [ruler_num,plane_num]=matlab.graphics.interaction.uiaxes.AxisPan.createAxisData(hObj.getDimension,point,transform,orig_ray);
        end

        function new_limits=axispan(~,rulernum,planenum,orig_limits,orig_ray,curr_ray)
            new_limits=matlab.graphics.interaction.uiaxes.AxisPan.axisPan(rulernum,planenum,orig_limits,orig_ray,curr_ray);
        end
    end

    methods(Static)
        function[ruler_num,plane_num]=createAxisData(dimension,point,transform,orig_ray)
            import matlab.graphics.interaction.internal.pan.findProjectedVectorOnPlane
            import matlab.graphics.interaction.internal.pan.transformPixelsToPoint
            test_ray=transformPixelsToPoint(transform,point+[10,10]);
            switch(dimension)
            case "x"
                ruler_num=1;
            case "y"
                ruler_num=2;
            case "z"
                ruler_num=3;
            end




            normal1=zeros(3,1);
            normal1(mod(ruler_num,3)+1)=1;




            normal2=zeros(3,1);
            normal2(mod(ruler_num+1,3)+1)=1;
            d1=findProjectedVectorOnPlane(orig_ray,test_ray,normal1);
            d2=findProjectedVectorOnPlane(orig_ray,test_ray,normal2);


            plane_num=1;
            if all(isfinite(d1))&&all(isfinite(d2))&&d2(ruler_num)>d1(ruler_num)
                plane_num=2;
            elseif~all(isfinite(d1))
                plane_num=2;
            end
        end

        function new_limits=axisPan(rulernum,planenum,orig_limits,orig_ray,curr_ray)
            import matlab.graphics.interaction.internal.pan.findProjectedVectorOnPlane
            import matlab.graphics.interaction.internal.pan.calculatePannedLimits
            normal=zeros(3,1);



            if planenum==1



                normal(mod(rulernum,3)+1)=1;
                d=findProjectedVectorOnPlane(orig_ray,curr_ray,normal);
            elseif planenum==2



                normal(mod(rulernum+1,3)+1)=1;
                d=findProjectedVectorOnPlane(orig_ray,curr_ray,normal);
            end

            delta=zeros(3,1);
            delta(rulernum)=d(rulernum);
            new_limits=calculatePannedLimits(orig_limits,delta);
        end
    end
end
