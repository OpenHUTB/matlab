


classdef AbstractArtifactResolver<matlab.mixin.SetGet&alm.internal.UserMessageMixin&handle



    properties(Access=public,Hidden)
        InputArg_MetaData alm.internal.HandlerServiceMetaData;
        InputArg_Artifact alm.Artifact;
        InputArg_Graph alm.Graph;
        InputArg_Loader alm.internal.ArtifactLoader;
    end

    properties(Access=public)
        MetaData alm.internal.HandlerServiceMetaData;
        MainArtifact alm.Artifact;
        SelfContainedArtifact alm.Artifact;
        Graph alm.Graph;
        ParentArtifacts alm.Artifact;
        Storage alm.ArtifactStorage;
        StorageHandler alm.StorageHandler;
        ParentArtifact alm.Artifact;
        Loader alm.internal.ArtifactLoader;
    end

    methods(Access=protected)

        function h=AbstractArtifactResolver(metaData,artifact,g,loader)
            h.InputArg_MetaData=metaData;
            h.InputArg_Artifact=artifact;
            h.InputArg_Graph=g;
            h.InputArg_Loader=loader;
        end
    end

    methods(Abstract,Hidden)
        resolvedAddress=convertAddressSpace(h,slot,index);
        redirectedArtifact=redirectAddress(h,convertedAddress,slot,index);
    end
end
