classdef CoverageDataServiceResource<metric.DataServiceData




    properties
        CoverageFragment;
    end

    methods
        function this=CoverageDataServiceResource(id,artifactUuid)
            this=this@metric.DataServiceData(id,artifactUuid);
        end

    end
end
