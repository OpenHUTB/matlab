classdef SLTestSessionResultLoadSaveAdapter<alm.internal.AbstractArtifactLoadSaveAdapter




    properties(Access=private)
        AbsoluteFileAddress string;
    end

    methods
        function h=SLTestSessionResultLoadSaveAdapter(metaData,artifact,g)
            h=h@alm.internal.AbstractArtifactLoadSaveAdapter(metaData,artifact,g);

            if artifact.Type~=alm.internal.sltest.SLTestConstants.SL_TEST_SESSION_RESULT_FILE
                error(message('alm:handler_services:UnsupportedType',artifact.Type));
            end

        end



        function postCreate(h)
            h.AbsoluteFileAddress=...
            fullfile(h.StorageHandler.getAbsoluteAddress(h.MainArtifact.Address));
        end



        function b=isLoaded(h)
            [~,resultSetUuid,~]=fileparts(h.AbsoluteFileAddress);
            resultSetId=stm.internal.getResultSetIDsFromUUID(...
            char(resultSetUuid));
            if isempty(resultSetId)
                b=false;
            else
                b=true;
            end
        end



        function b=isDirty(~)
            b=false;
        end
    end
end
