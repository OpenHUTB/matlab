


classdef SLTestResultHandlerService<alm.internal.AbstractHandlerService

    methods
        function h=SLTestResultHandlerService(metaData)
            h=h@alm.internal.AbstractHandlerService(metaData);
        end

        function factory=createArtifactFactory(~,metaData,storage,g)
            factory=alm.internal.sltest.SLTestResultArtifactFactory(metaData,storage,g);
        end

        function handler=createArtifactHandler(~,metaData,artifact,g)
            handler=alm.internal.sltest.SLTestResultArtifactHandler(metaData,artifact,g);
        end

        function adapter=createLoadSaveAdapter(~,metaData,artifact,g)
            switch(string(artifact.Type))
            case alm.internal.sltest.SLTestConstants.SL_TEST_RESULT_FILE

                adapter=alm.internal.sltest.SLTestResultLoadSaveAdapter(...
                metaData,artifact,g);

            case alm.internal.sltest.SLTestConstants.SL_TEST_SESSION_RESULT_FILE

                adapter=alm.internal.sltest.SLTestSessionResultLoadSaveAdapter(...
                metaData,artifact,g);

            otherwise
                adapter=[];
            end
        end
    end
end
