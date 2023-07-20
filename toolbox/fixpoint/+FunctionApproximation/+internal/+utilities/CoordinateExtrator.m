classdef CoordinateExtrator<handle





    methods(Access={?FunctionApproximation.internal.AbstractUtils})
        function this=CoordinateExtrator()
        end
    end

    methods
        function coordinates=extract(~,linearIndices,tableSize,grid)
            numDimensions=numel(grid);
            coordinates=zeros(numel(linearIndices),numDimensions);
            subs=cell(1,numDimensions);
            for i=1:numel(linearIndices)
                [subs{:}]=ind2sub(tableSize,linearIndices(i));
                for k=1:numDimensions
                    coordinates(i,k)=grid{k}(subs{k});
                end
            end
        end
    end
end
