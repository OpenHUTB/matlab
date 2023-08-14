classdef EvenSpacingTableDataCreator<FunctionApproximation.internal.tabledatacreator.Interface














    properties(SetAccess=private)
        TableValueCreator=FunctionApproximation.internal.tabledatacreator.TableValueCreator();
    end

    methods

        function data=getData(this,functionWrapper,grid)
            nDimensions=grid.RangeObject.NumberOfDimensions;
            data=cell(1,nDimensions+1);
            data(end)=this.TableValueCreator.getData(functionWrapper,grid);
            for ii=1:nDimensions
                data{ii}=cell(1,2);
                data{ii}{1}=grid.SingleDimensionDomains{ii}(1);
                data{ii}{2}=diff(grid.SingleDimensionDomains{ii}([1,2]));
            end
        end
    end
end