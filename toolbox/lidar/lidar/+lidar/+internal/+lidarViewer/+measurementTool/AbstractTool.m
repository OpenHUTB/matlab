





classdef(Abstract)AbstractTool<handle

    properties(Abstract,Constant)

ToolName
    end

    events

UserDrawingFinished
    end

    methods(Abstract)
        createToolObj(this,pos,ax)


        doMeasureMetric(this,ax,cMap)


        stopMeasuringMetric(this,isUserMeasuring)



    end

    methods(Access=protected)

        function lineObj=create3DlineObj(this,axesHandle,cMap)


            lineObj=vision.roi.Polyline3D(axesHandle,...
            'Color',this.getColor(cMap));
        end


        function cuboidObj=create3DCuboidObj(this,axesHandle,cMap)


            cuboidObj=images.roi.Cuboid(axesHandle,...
            'Color',this.getColor(cMap));
        end


        function pointObj=create3DPointObj(this,axesHandle,cMap)


            pointObj=lidar.roi.Point3D(axesHandle,...
            'Color',this.getColor(cMap));
        end
    end
    methods

        function color=getColor(this,cMap)

            switch cMap
            case 0
                color=[1,1,0];
            case 1
                color=[0,1,0];
            case 2
                color=[1,0,1];
            case 3
                color=[0,0,1];
            otherwise
                color=[0,1,1];
            end
        end


        function updateAllInteractions(this,TF,axes)
            child=axes.Children;
            if TF
                for i=1:numel(child)
                    if isa(child(i),'vision.roi.Polyline3D')||...
                        isa(child(i),'images.roi.Cuboid')||...
                        isa(child(i),'lidar.roi.Point3D')
                        child(i).InteractionsAllowed='all';
                    end
                end
            else
                for i=1:numel(child)
                    if isa(child(i),'vision.roi.Polyline3D')||...
                        isa(child(i),'images.roi.Cuboid')||...
                        isa(child(i),'lidar.roi.Point3D')
                        child(i).InteractionsAllowed='none';
                    end
                end
            end
        end
    end
end
