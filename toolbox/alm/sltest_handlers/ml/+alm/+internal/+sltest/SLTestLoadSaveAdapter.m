classdef SLTestLoadSaveAdapter<alm.internal.AbstractArtifactLoadSaveAdapter




    properties(Access=private)
        AbsoluteFileAddress string;
    end

    methods
        function h=SLTestLoadSaveAdapter(metaData,artifact,g)
            h=h@alm.internal.AbstractArtifactLoadSaveAdapter(metaData,artifact,g);

            if artifact.Type~=alm.internal.sltest.SLTestConstants.SL_TEST_FILE
                error(message('alm:handler_services:UnsupportedType',artifact.Type));
            end

        end



        function postCreate(h)
            h.AbsoluteFileAddress=...
            fullfile(h.StorageHandler.getAbsoluteAddress(h.MainArtifact.Address));
        end



        function b=isLoaded(h)
            b=stm.internal.isTestFileOpen(h.AbsoluteFileAddress);
        end



        function b=isDirty(h)
            tf=alm.internal.sltest.Utils.getTestFileObj(h.AbsoluteFileAddress);
            if~isempty(tf)
                b=tf.Dirty;
            else
                error(message('alm:handler_services:FileNotLoaded',h.MainArtifact.Address));
            end
        end



        function b=save(h)
            tf=alm.internal.sltest.Utils.getTestFileObj(h.AbsoluteFileAddress);
            if~isempty(tf)
                tf.saveToFile();
                b=true;
            else
                error(message('alm:handler_services:FileNotLoaded',h.MainArtifact.Address));
            end
        end



        function resource=load(h,~)




            sltest.testmanager.load(h.AbsoluteFileAddress);

            function close(absoluteFileAddress)
                tf=alm.internal.sltest.Utils.getTestFileObj(absoluteFileAddress);
                if~isempty(tf)
                    tf.close();
                end
            end

            address=h.AbsoluteFileAddress;
            resource=alm.internal.LoadedArtifact(h.MainArtifact.UUID,...
            @()close(address));

        end
    end
end
