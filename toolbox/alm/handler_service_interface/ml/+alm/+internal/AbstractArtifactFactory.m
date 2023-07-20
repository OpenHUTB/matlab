


classdef AbstractArtifactFactory<matlab.mixin.SetGet&handle





    properties(Access=public,Hidden)
        InputArg_MetaData alm.internal.HandlerServiceMetaData;
        InputArg_Storage alm.ArtifactStorage;
        InputArg_Graph alm.Graph;
    end

    properties(Access=public)
        MetaData alm.internal.HandlerServiceMetaData;
        Storage alm.ArtifactStorage;
        Graph alm.Graph;
        StorageHandler alm.StorageHandler;
    end

    methods(Access=protected)

        function h=AbstractArtifactFactory(metaData,storage,g)
            h.InputArg_MetaData=metaData;
            h.InputArg_Storage=storage;
            h.InputArg_Graph=g;
        end
    end

    methods(Abstract)
        type=getSelfContainedType(h,address);
    end

    methods
        function das=getDirtyArtifacts(~)
            das=alm.internal.AddressAndType.empty(0,0);
        end
    end
end
