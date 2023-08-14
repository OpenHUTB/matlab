


classdef AbstractArtifactHandler<matlab.mixin.SetGet&alm.internal.UserMessageMixin&handle



    properties(Access=public,Hidden)
        InputArg_MetaData alm.internal.HandlerServiceMetaData;
        InputArg_Artifact alm.Artifact;
        InputArg_Graph alm.Graph;

        SharedState alm.internal.SharedHandlerState;
    end

    properties(Access=public)
        MetaData alm.internal.HandlerServiceMetaData;
        MainArtifact alm.Artifact;
        SelfContainedArtifact alm.Artifact;
        ParentArtifacts alm.Artifact;
    end

    properties(Dependent)
        Graph alm.Graph;
        Storage alm.ArtifactStorage;
        StorageHandler alm.StorageHandler;
        Loader alm.internal.ArtifactLoader;
    end

    methods(Access=protected)

        function h=AbstractArtifactHandler(metaData,artifact,g)
            h.InputArg_MetaData=metaData;
            h.InputArg_Artifact=artifact;
            h.InputArg_Graph=g;
        end
    end

    methods
        function g=get.Graph(h)
            g=h.SharedState.Graph;
        end
        function g=get.Storage(h)
            g=h.SharedState.Storage;
        end
        function g=get.StorageHandler(h)
            g=h.SharedState.StorageHandler;
        end
        function g=get.Loader(h)
            g=h.SharedState.Loader;
        end
    end

    methods(Access=protected)
        function startNestedAnalysis(h,artifact)
            mgr=alm.internal.HandlerServiceManager.get();
            service=mgr.getServiceByType(artifact.Type);
            if~isempty(service)
                handler=service.createNestedArtifactHandler(artifact,h.SharedState);
                handler.analyze();
            end
        end
    end

    methods(Abstract,Hidden)

        analyze(h);
        openElement(h);
        openFile(h);

    end

    methods(Hidden)
        function postCreate(~)
        end
    end
end
