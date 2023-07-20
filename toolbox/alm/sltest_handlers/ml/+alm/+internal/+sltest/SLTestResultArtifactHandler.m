


classdef SLTestResultArtifactHandler<alm.internal.AbstractArtifactHandler

    properties(Constant)
        CUSTOM_KEY_HAS_SIM_RESULT="HasSimResult";
    end

    properties
        AbsoluteFileAddress string;
    end

    methods
        function h=SLTestResultArtifactHandler(metaData,container,g)
            h=h@alm.internal.AbstractArtifactHandler(metaData,container,g);
        end



        function postCreate(h)
            h.AbsoluteFileAddress=...
            fullfile(h.StorageHandler.getAbsoluteAddress(h.SelfContainedArtifact.Address));
        end



        function analyze(h)


            licPrev=alm.internal.sltest.SLTestLicenseCheckoutOverride();%#ok<NASGU>  


            h.MainArtifact.Derived=true;



            rscs=h.Loader.load(h.MainArtifact,h.Graph);%#ok<NASGU>

            if endsWith(h.AbsoluteFileAddress,'.mldatx')







                release=string(stm.internal.getPkgRelease(h.AbsoluteFileAddress));
                if release<"R2020b"
                    error(message('alm:sltest_handlers:TestResultFileIncompatible',h.AbsoluteFileAddress,"R2020b"));
                end

                [resultSetUuidsOfFile,~]=...
                stm.internal.getResultsFileLoadStatus(...
                h.AbsoluteFileAddress);








                nResults=numel(resultSetUuidsOfFile);
                resultSetUuidsOfFile=unique(resultSetUuidsOfFile);
                if numel(resultSetUuidsOfFile)<nResults
                    error(message("alm:sltest_handlers:DuplicateResultSets",h.AbsoluteFileAddress));
                end

                resultSets=sltest.testmanager.ResultSet.empty(...
                numel(resultSetUuidsOfFile),0);
                for i=1:numel(resultSetUuidsOfFile)
                    resultSetUuid=char(resultSetUuidsOfFile(i));
                    rsID=stm.internal.getResultSetIDsFromUUID(char(resultSetUuid));
                    resultSet=sltest.testmanager.ResultSet([],rsID);
                    resultSets(i)=resultSet;
                end

            elseif endsWith(h.AbsoluteFileAddress,'.sltsrf')

                resultSets=[];
                [~,resultSetUuid,~]=fileparts(h.AbsoluteFileAddress);
                resultSetId=stm.internal.getResultSetIDsFromUUID(...
                char(resultSetUuid));
                if~isempty(resultSetId)

                    resultSets=sltest.testmanager.ResultSet([],resultSetId);
                    if~isempty(resultSets)
                        h.MainArtifact.Label=resultSets.Name;
                    end
                end

            end


            for i=1:numel(resultSets)


                v=alm.internal.sltest.visitor.TestResultHandler(h);
                traverser=alm.internal.sltest.SLTestResultTraverser(v);
                traverser.run(resultSets(i));



                testCaseArts=h.Graph.getAllArtifacts("sl_test_case_result");
                for testCaseArt=testCaseArts
                    if~testCaseArt.hasCustomProperty(...
                        alm.internal.sltest.SLTestResultArtifactHandler.CUSTOM_KEY_HAS_SIM_RESULT)
                        h.notifyUser("warn",message(...
                        'alm:sltest_handlers:ResultWithoutSimMode',...
                        testCaseArt.Label,alm.internal.createOpenArtifactHyperlink(testCaseArt.getSelfContainedArtifact())));
                    end
                end

            end

        end



        function openFile(h)
            import alm.internal.sltest.SLTestResultArtifactHandler;

            if endsWith(h.AbsoluteFileAddress,'.mldatx')
                release=string(stm.internal.getPkgRelease(h.AbsoluteFileAddress));
                if release>="R2020b"
                    sltest.testmanager.importResults(...
                    h.AbsoluteFileAddress,'UniqueImport',true);


                    [loadedResultSetUUIDs,~]=...
                    stm.internal.getResultsFileLoadStatus(h.AbsoluteFileAddress);

                    if~isempty(loadedResultSetUUIDs)
                        stm.internal.util.highlightTestResult(char(loadedResultSetUUIDs(1)));
                    end
                else


                    sltest.testmanager.importResults(h.AbsoluteFileAddress);
                    rss=sltest.testmanager.getResultSets();
                    if~isempty(rss)
                        stm.internal.util.highlightTestResult(rss(end).getID());
                    end




                end
            elseif endsWith(h.AbsoluteFileAddress,'.sltsrf')
                [~,resultSetUuid,~]=fileparts(h.AbsoluteFileAddress);
                resultSetId=stm.internal.getResultSetIDsFromUUID(char(resultSetUuid));
                if~isempty(resultSetId)
                    stm.internal.util.highlightTestResult(resultSetUuid);
                end
            end
        end



        function openElement(h)
            import alm.internal.sltest.SLTestResultArtifactHandler;

            if endsWith(h.AbsoluteFileAddress,'.mldatx')
                sltest.testmanager.importResults(...
                h.AbsoluteFileAddress,'UniqueImport',true);
                stm.internal.util.highlightTestResult(h.MainArtifact.Address);
            elseif endsWith(h.AbsoluteFileAddress,'.sltsrf')
                [~,resultSetUuid,~]=fileparts(h.AbsoluteFileAddress);
                resultSetId=stm.internal.getResultSetIDsFromUUID(...
                char(resultSetUuid));
                if isempty(resultSetId)

                else
                    stm.internal.util.highlightTestResult(...
                    h.MainArtifact.Address);
                end
            end

        end
    end
end
