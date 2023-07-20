classdef DesignCostDataServiceResource<metric.DataServiceData




    properties(Constant)
        EstimationData=metric.internal.EstimationData
    end

    methods
        function this=DesignCostDataServiceResource(id,artifactUuid)
            this=this@metric.DataServiceData(id,artifactUuid);
        end

    end
end


