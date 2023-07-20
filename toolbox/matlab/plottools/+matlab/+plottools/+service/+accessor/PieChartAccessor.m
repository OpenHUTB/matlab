classdef PieChartAccessor<matlab.plottools.service.accessor.BaseAxesAccessor




    methods
        function obj=PieChartAccessor()
            obj=obj@matlab.plottools.service.accessor.BaseAxesAccessor();
        end

        function id=getIdentifier(~)
            id='piechart';
        end
    end


    methods(Access='protected')
        function result=supportsXLabel(~)
            result=false;
        end

        function result=supportsYLabel(~)
            result=false;
        end

        function result=supportsGrid(~)
            result=false;
        end

        function result=supportsXGrid(~)
            result=false;
        end

        function result=supportsYGrid(~)
            result=false;
        end

        function result=supportsZGrid(~)
            result=false;
        end
    end
end
