classdef GeoAxesAccessor<matlab.plottools.service.accessor.BaseAxesAccessor



    methods
        function obj=GeoAxesAccessor()
            obj=obj@matlab.plottools.service.accessor.BaseAxesAccessor();
        end

        function id=getIdentifier(~)
            id='matlab.graphics.axis.GeographicAxes';
        end
    end


    methods(Access='protected')
        function result=getGrid(obj)
            result=obj.ReferenceObject.Grid;
        end
    end


    methods(Access='protected')
        function setGrid(obj,value)
            obj.ReferenceObject.Grid=value;
        end
    end
end

