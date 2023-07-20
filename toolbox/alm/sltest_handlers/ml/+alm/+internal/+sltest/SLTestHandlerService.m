classdef SLTestHandlerService<alm.internal.AbstractHandlerService




    methods
        function h=SLTestHandlerService(metaData)
            h=h@alm.internal.AbstractHandlerService(metaData);
        end



        function factory=createArtifactFactory(~,metaData,storage,g)
            factory=alm.internal.sltest.SLTestArtifactFactory(metaData,storage,g);
        end



        function handler=createArtifactHandler(~,metaData,artifact,g)
            handler=alm.internal.sltest.SLTestArtifactHandler(metaData,artifact,g);
        end



        function adapter=createLoadSaveAdapter(~,metaData,artifact,g)
            if artifact.Type==alm.internal.sltest.SLTestConstants.SL_TEST_FILE
                adapter=alm.internal.sltest.SLTestLoadSaveAdapter(metaData,artifact,g);
            else
                adapter=[];
            end
        end



        function adapter=createResolver(~,metaData,artifact,g,loader)
            if artifact.Type==alm.internal.sltest.SLTestConstants.SL_TEST_FILE
                adapter=alm.internal.sltest.SLTestResolver(metaData,artifact,g,loader);
            else
                adapter=[];
            end
        end
    end
end
