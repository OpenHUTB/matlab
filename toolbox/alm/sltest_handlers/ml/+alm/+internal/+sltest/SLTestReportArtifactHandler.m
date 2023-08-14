classdef SLTestReportArtifactHandler<alm.internal.AbstractArtifactHandler




    methods
        function h=SLTestReportArtifactHandler(metaData,container,g)
            h=h@alm.internal.AbstractArtifactHandler(metaData,container,g);
        end

        function analyze(h)

            ofCache=alm.internal.OpaqueFileCache.getInstance();
            ofContents=ofCache.pop(h.MainArtifact.Address);
            if isempty(ofContents)
                return
            end

            h.MainArtifact.Derived=true;
            graph=ofContents.Graph;



            reportFile=graph.getAllArtifacts('sl_test_report_file');
            if reportFile.LastAnalysisStatus==alm.AnalysisStatusType.ERROR
                error(message(...
                'alm:sltest_handlers:TestResultReportFileIncompatible',...
                reportFile.Address,"R2020b"));
            end


            for artifact=graph.getAllArtifacts()
                if~artifact.isFile()
                    h.Graph.importArtifact(artifact);
                end
            end


            for relationship=graph.getAllRelationships()
                if relationship.IsConnected
                    h.Graph.addRelationship(...
                    relationship.SourceItem,...
                    relationship.Type,...
                    relationship.DestinationItem);
                else
                    relationshipBuilder=...
                    alm.gdb.UnresolvedRelationshipBuilder.createRelationshipFromRelationship(relationship);
                    relationshipBuilder.createIntoGraph(h.Graph);
                end
            end

        end

        function openFile(h)
            absoluteFilePath=h.StorageHandler.getAbsoluteAddress(...
            h.MainArtifact.Address);
            rptgen.rptview(absoluteFilePath);
        end

        function openElement(h)
            absoluteFilePath=h.StorageHandler.getAbsoluteAddress(...
            h.MainArtifact.Address);
            rptgen.rptview(absoluteFilePath);
        end

    end

end
