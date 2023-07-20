


classdef AbstractHandlerService<matlab.mixin.SetGet&handle





    properties(Access=public,Hidden)
        InputArg_MetaData alm.internal.HandlerServiceMetaData;
    end

    properties(Access=public)


        MetaData alm.internal.HandlerServiceMetaData;
    end

    methods(Access=protected)

        function h=AbstractHandlerService(metaData)
            h.InputArg_MetaData=metaData;
        end
    end


    methods(Abstract)

        factory=createArtifactFactory(h,metaData,storage,g);

        handler=createArtifactHandler(h,metaData,artifact,g);

    end


    methods

        function adapter=createLoadSaveAdapter(h,metaData,artifact,g)
            adapter=[];
        end


        function resolver=createResolver(h,metaData,artifact,g,loader)
            resolver=[];
        end
    end
end
