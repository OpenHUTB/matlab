classdef ZCBlockDiagramLoadSaveAdapter<alm.internal.AbstractArtifactLoadSaveAdapter

    properties(Access=private)
        SLAdapter;
    end

    methods
        function h=ZCBlockDiagramLoadSaveAdapter(metaData,artifact,g)
            h=h@alm.internal.AbstractArtifactLoadSaveAdapter(metaData,artifact,g);

            if artifact.Type~=alm.internal.zc.ZCConstants.ZC_BLOCK_DIAGRAM
                error(message('alm:handler_services:UnsupportedType',artifact.Type));
            end

        end



        function postCreate(h)
            mgr=alm.internal.HandlerServiceManager.get();
            service=mgr.getService(alm.internal.zc.ZCConstants.SIMULINK_SERVICE_ID);
            g=alm.Graph;
            g.importStorage(h.Storage);
            for a=h.ParentArtifacts
                g.importArtifact(a);
            end
            mainArt=g.importArtifact(h.MainArtifact);
            mainArt.Type=alm.internal.zc.ZCConstants.SL_BLOCK_DIAGRAM;
            h.SLAdapter=service.createLoadSaveAdapter(mainArt,g);
        end



        function b=isLoaded(h)
            b=h.SLAdapter.isLoaded();
        end



        function b=isDirty(h)
            b=h.SLAdapter.isDirty();
        end



        function b=save(h)
            b=h.SLAdapter.save();
        end



        function resource=load(h,~)
            resource=h.SLAdapter.load();
        end
    end
end
