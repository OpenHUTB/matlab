classdef TableValueCreator<FunctionApproximation.internal.tabledatacreator.Interface







    methods(Access=?FunctionApproximation.internal.tabledatacreator.Interface)
        function this=TableValueCreator()
        end
    end

    methods
        function data=getData(~,functionWrapper,grid)
            segmentValues=getSets(grid);
            if grid.RangeObject.NumberOfDimensions<2
                data{1}=functionWrapper.evaluate(segmentValues)';
            else
                data{1}=reshape(functionWrapper.evaluate(segmentValues),grid.GridSize);
            end
        end
    end
end
