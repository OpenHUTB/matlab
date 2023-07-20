classdef TestHandler<alm.internal.sltest.ISLTestVisitor




    properties
        ParentStack=[];
        ArtifactHandler;
    end

    methods

        function h=TestHandler(handler)
            h.ArtifactHandler=handler;
            h.ParentStack=handler.MainArtifact;
        end

        function preOrderVisit(h,t)

            g=h.ArtifactHandler.Graph;
            if~isempty(h.ParentStack)
                prevArt=h.ParentStack(end);
            end

            switch class(t)

            case 'sltest.testmanager.TestFile'


                currentArt=h.ArtifactHandler.Graph.createArtifact(...
                alm.internal.sltest.Utils.getSpecUUID(t),...
                prevArt);
                currentArt.Type="sl_test_file_element";
                currentArt.Label=t.Name;

            case 'sltest.testmanager.TestSuite'


                currentArt=h.ArtifactHandler.Graph.createArtifact(...
                alm.internal.sltest.Utils.getSpecUUID(t),...
                prevArt);
                currentArt.Type="sl_test_suite";
                currentArt.Label=t.Name;

                if feature('ALMSLTestSubfileChecksum')
                    currentArt.Checksum=t.getProperty('RevisionUUID');
                end

            case 'sltest.testmanager.TestCase'


                currentArt=h.ArtifactHandler.Graph.createArtifact(...
                alm.internal.sltest.Utils.getSpecUUID(t),...
                prevArt);
                currentArt.Type="sl_test_case";
                currentArt.Label=t.Name;

                if feature('ALMSLTestSubfileChecksum')
                    currentArt.Checksum=t.getProperty('RevisionUUID');
                end








                if~t.RunOnTarget{1}
                    currentArt.setCustomProperty("SimulationMode",...
                    t.getProperty("SimulationMode"));
                end


                testedModel=t.getProperty('model');



                if~isempty(testedModel)

                    if isempty(t.getProperty('HARNESSOWNER'))


                        b=alm.gdb.UnresolvedRelationshipBuilder.createSymbolRelationshipToFile(...
                        currentArt,alm.RelationshipType.TRACES,...
                        testedModel,{'.slx','.mdl','.slxp'},...
                        string(testedModel),true,"sl_symbol_criteria");
                        b.createIntoGraph(g);

                        b=alm.gdb.UnresolvedRelationshipBuilder.createSymbolRelationshipToFile(...
                        currentArt,alm.RelationshipType.REQUIRES,...
                        testedModel,{'.slx','.mdl','.slxp'},...
                        string(testedModel),true,"sl_symbol_criteria");
                        b.createIntoGraph(g);

                    elseif strcmp(testedModel,t.getProperty('HARNESSOWNER'))



                        b=alm.gdb.UnresolvedRelationshipBuilder.createSymbolRelationshipToFile(...
                        currentArt,alm.RelationshipType.TRACES,...
                        testedModel,{'.slx','.mdl','.slxp'},...
                        string(testedModel),true,"sl_symbol_criteria");
                        b.createIntoGraph(g);

                        b=alm.gdb.UnresolvedRelationshipBuilder.createSymbolRelationshipToFile(...
                        currentArt,alm.RelationshipType.REQUIRES,...
                        testedModel,{'.slx','.mdl','.slxp'},...
                        string(testedModel),true,"sl_symbol_criteria");
                        b.createIntoGraph(g);

                    else



                        b=alm.gdb.UnresolvedRelationshipBuilder.createSymbolRelationshipToFile(...
                        currentArt,alm.RelationshipType.TRACES,...
                        testedModel,{'.slx','.mdl','.slxp'},...
                        [testedModel,string(t.getProperty('HARNESSOWNER'))],true,"sl_symbol_criteria");
                        b.createIntoGraph(g);

                        b=alm.gdb.UnresolvedRelationshipBuilder.createSymbolRelationshipToFile(...
                        currentArt,alm.RelationshipType.REQUIRES,...
                        testedModel,{'.slx','.mdl','.slxp'},...
                        [testedModel,string(t.getProperty('HARNESSOWNER'))],true,"sl_symbol_criteria");
                        b.createIntoGraph(g);

                    end
                end

            case 'sltest.testmanager.TestIteration'


                currentArt=h.ArtifactHandler.Graph.createArtifact(...
                t.getIterationProperties.uuid,...
                prevArt);
                currentArt.Type="sl_test_iteration";
                currentArt.Label=t.Name;


                if feature('ALMSLTestSubfileChecksum')
                    currentArt.Checksum=t.RevisionUUID;
                end

            otherwise


            end

            h.ParentStack=[h.ParentStack,currentArt];
        end

        function postOrderVisit(h,testObj)
            h.ParentStack(end)=[];
        end

        function results=getResults(h)
            results=[];
        end

        function b=stop(h,testObj)
            b=false;
        end
    end
end
