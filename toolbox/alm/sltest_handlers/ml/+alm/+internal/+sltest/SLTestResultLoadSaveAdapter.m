classdef SLTestResultLoadSaveAdapter<alm.internal.AbstractArtifactLoadSaveAdapter




    properties(Access=private)
        AbsoluteFileAddress string;
    end

    methods
        function h=SLTestResultLoadSaveAdapter(metaData,artifact,g)
            h=h@alm.internal.AbstractArtifactLoadSaveAdapter(metaData,artifact,g);

            if artifact.Type~=alm.internal.sltest.SLTestConstants.SL_TEST_RESULT_FILE
                error(message('alm:handler_services:UnsupportedType',artifact.Type));
            end

        end



        function postCreate(h)
            h.AbsoluteFileAddress=...
            fullfile(h.StorageHandler.getAbsoluteAddress(h.MainArtifact.Address));
        end



        function b=isLoaded(h)
            release=string(stm.internal.getPkgRelease(char(h.AbsoluteFileAddress)));
            if release>="R2020b"
                [~,unloadedResultSetUUIDs]=...
                stm.internal.getResultsFileLoadStatus(char(h.AbsoluteFileAddress));
                b=isempty(unloadedResultSetUUIDs);
            else
                error(message('alm:sltest_handlers:TestResultFileIncompatible',...
                h.AbsoluteFileAddress,"R2020b"));
            end
        end



        function b=isDirty(~)
            b=false;
        end



        function resource=load(h,~)

            release=string(stm.internal.getPkgRelease(char(h.AbsoluteFileAddress)));
            if release>="R2020b"
                sltest.testmanager.importResults(h.AbsoluteFileAddress,...
                'UniqueImport',true,...
                'PartialLoad',true);
            else
                error(message('alm:sltest_handlers:TestResultFileIncompatible',...
                h.AbsoluteFileAddress,"R2020b"));
            end

            function close(absoluteFileAddress)
                [loadedResultSetUUIDs,~]=...
                stm.internal.getResultsFileLoadStatus(char(absoluteFileAddress));

                for i=1:numel(loadedResultSetUUIDs)
                    resultSetUuid=char(loadedResultSetUUIDs(i));
                    rsID=stm.internal.getResultSetIDsFromUUID(resultSetUuid);
                    if stm.internal.isPartiallyLoaded(rsID)
                        resultSet=sltest.testmanager.ResultSet([],rsID);
                        resultSet.remove();
                    end
                end
            end

            address=h.AbsoluteFileAddress;
            resource=alm.internal.LoadedArtifact(h.MainArtifact.UUID,...
            @()close(address));

        end
    end
end
