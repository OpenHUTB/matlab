classdef SLTestReportHandlerService<alm.internal.AbstractHandlerService




    methods
        function h=SLTestReportHandlerService(metaData)
            h=h@alm.internal.AbstractHandlerService(metaData);
        end

        function factory=createArtifactFactory(~,metaData,storage,g)
            factory=alm.internal.sltest.SLTestReportArtifactFactory(metaData,storage,g);
        end

        function handler=createArtifactHandler(~,metaData,artifact,g)
            handler=alm.internal.sltest.SLTestReportArtifactHandler(metaData,artifact,g);
        end
    end
end
