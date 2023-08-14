classdef ExplicitValueTableDataCreator<FunctionApproximation.internal.tabledatacreator.Interface









    properties(SetAccess=private)
        TableValueCreator=FunctionApproximation.internal.tabledatacreator.TableValueCreator();
    end

    methods

        function data=getData(this,functionWrapper,grid)
            nDimensions=grid.RangeObject.NumberOfDimensions;
            data=cell(1,nDimensions+1);
            data(end)=getData(this.TableValueCreator,functionWrapper,grid);
            data(1:nDimensions)=grid.SingleDimensionDomains;
        end
    end
end