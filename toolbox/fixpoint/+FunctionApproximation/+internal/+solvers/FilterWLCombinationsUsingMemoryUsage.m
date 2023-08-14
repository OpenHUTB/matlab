classdef FilterWLCombinationsUsingMemoryUsage<handle













    methods
        function combinations=filter(~,combinations,serializeableData)
            memoryUsage=serializeableData.MemoryUsage.getBits();
            gridSize=cellfun(@(x)numel(x),serializeableData.Data(1:end-1));
            memoryToStore=zeros(size(combinations,1),1);
            for ii=1:numel(memoryToStore)
                memoryToStore(ii)=...
                FunctionApproximation.internal.getLUTDataMemoryUsage(...
                serializeableData.Spacing,...
                gridSize,...
                combinations(ii,1:end-1),...
                combinations(ii,end));
            end
            [memoryToStore,indices]=sort(memoryToStore);
            combinations=combinations(indices,:);


            combinations=combinations(memoryToStore<=memoryUsage,:);
        end
    end
end


