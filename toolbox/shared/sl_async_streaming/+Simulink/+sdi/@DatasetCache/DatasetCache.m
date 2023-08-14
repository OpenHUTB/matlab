classdef(Hidden=true)DatasetCache<Simulink.SimulationData.Storage.RamDatasetStorage






    methods


        function obj=DatasetCache(numElements)
            obj=obj@Simulink.SimulationData.Storage.RamDatasetStorage();
            obj.Elements=cell(1,numElements);
        end


        function ret=isCached(this,idx)
            ret=idx>0&&idx<=length(this.Elements)&&~isempty(this.Elements{idx});
        end


        function this=cacheElement(this,idx,el)
            this.Elements{idx}=el;
        end
    end
end
