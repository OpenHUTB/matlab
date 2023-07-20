classdef ZCHandlerService<alm.internal.AbstractHandlerService




    methods
        function h=ZCHandlerService(metaData)
            h=h@alm.internal.AbstractHandlerService(metaData);
        end

        function factory=createArtifactFactory(~,metaData,storage,g)
            factory=alm.internal.zc.ZCArtifactFactory(metaData,storage,g);
        end

        function handler=createArtifactHandler(~,metaData,artifact,g)
            handler=alm.internal.zc.ZCArtifactHandler(metaData,artifact,g);
        end

        function adapter=createLoadSaveAdapter(~,metaData,artifact,g)
            if artifact.Type==alm.internal.zc.ZCConstants.ZC_BLOCK_DIAGRAM
                adapter=alm.internal.zc.ZCBlockDiagramLoadSaveAdapter(metaData,artifact,g);
            else
                adapter=[];
            end
        end

        function adapter=createResolver(~,metaData,artifact,g,loader)
            if artifact.Type==alm.internal.zc.ZCConstants.ZC_BLOCK_DIAGRAM
                adapter=alm.internal.zc.ZCBlockDiagramResolver(metaData,artifact,g,loader);
            else
                adapter=[];
            end
        end
    end
end
