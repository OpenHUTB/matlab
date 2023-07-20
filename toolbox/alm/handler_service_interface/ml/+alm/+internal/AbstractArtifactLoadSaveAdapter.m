classdef AbstractArtifactLoadSaveAdapter<matlab.mixin.SetGet






    properties(Access=public,Hidden)
        InputArg_MetaData alm.internal.HandlerServiceMetaData
        InputArg_Artifact alm.Artifact
        InputArg_Graph alm.Graph
    end

    properties(Access=public)
        MetaData alm.internal.HandlerServiceMetaData
        MainArtifact alm.Artifact
        ParentArtifacts alm.Artifact
        Storage alm.ArtifactStorage
        StorageHandler alm.StorageHandler
    end

    methods(Access=protected)
        function h=AbstractArtifactLoadSaveAdapter(metaData,artifact,g)



            h.InputArg_MetaData=metaData;
            h.InputArg_Artifact=artifact;
            h.InputArg_Graph=g;
        end
    end


    methods(Abstract,Hidden)
        b=isLoaded(h);
        b=isDirty(h);
    end



    methods(Hidden)



        function postCreate(~)
        end

        function resource=load(~,~)
            resource=[];
        end

        function b=save(~)
            b=true;
        end
    end

end
