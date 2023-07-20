classdef TestResultHandler<alm.internal.sltest.ISLTestVisitor




    properties
        ParentStack=[];
        ArtifactHandler;
        AbsoluteFileAddress string="";
    end

    methods

        function h=TestResultHandler(handler)
            h.ArtifactHandler=handler;
            h.ParentStack=[h.ParentStack,handler.MainArtifact];
            h.AbsoluteFileAddress=handler.StorageHandler.getAbsoluteAddress(...
            handler.MainArtifact.Address);
        end

        function preOrderVisit(h,t)

            g=h.ArtifactHandler.Graph;
            if~isempty(h.ParentStack)
                prevArt=h.ParentStack(end);
            else
                prevArt=[];
            end






            uuid=alm.internal.sltest.Utils.getResultUUID(t);

            if isempty(uuid)


                currentArt=prevArt;
            else

                switch class(t)
                case 'sltest.testmanager.ResultSet'



                    currentArt=h.ArtifactHandler.Graph.createArtifact(...
                    uuid,prevArt);
                    currentArt.Type="sl_test_resultset";
                    currentArt.Label=t.Name;

                case 'sltest.testmanager.TestCaseResult'






                    r=h.ArtifactHandler.Graph.try_createArtifact(...
                    uuid,prevArt);
                    if r.Ok
                        currentArt=r.Value;
                        currentArt.Type="sl_test_case_result";
                        currentArt.Label=t.Name;
                    else
                        error(message("alm:sltest_handlers:DuplicateResultSets",h.AbsoluteFileAddress));
                    end





                    anySimResult=false;



                    if isempty(t.getIterationResults())
                        anySimResult=h.isSimulationResult(t);
                    else
                        iterObjs=t.getIterationResults;
                        for iterObj=iterObjs
                            anySimResult=h.isSimulationResult(iterObj);
                            if(anySimResult)
                                break;
                            end
                        end
                    end



                    if anySimResult
                        currentArt.Label=[t.Name,' [Sim. Result]'];
                        currentArt.setCustomProperty(...
                        alm.internal.sltest.SLTestResultArtifactHandler.CUSTOM_KEY_HAS_SIM_RESULT','');
                    else
                        currentArt.Label=[t.Name,' [Result]'];
                    end





                    project=matlab.project.currentProject;
                    if isempty(project)
                        projectRoot=pwd;
                    else
                        projectRoot=project.RootFolder;
                    end

                    [testFilePath,success]=alm.internal.utils.resolveFile(...
                    projectRoot,t.TestFilePath);%#ok<ASGLU>


                    if~isempty(testFilePath)
                        testCaseUuid=t.UUID;
                        b=alm.gdb.UnresolvedRelationshipBuilder.createRelationshipToFile(...
                        currentArt,...
                        alm.RelationshipType.TRACES,...
                        testFilePath,string(testCaseUuid));
                        b.createIntoGraph(g);
                    end
                end
            end

            h.ParentStack=[h.ParentStack,currentArt];

        end

        function postOrderVisit(h,testObj)%#ok<INUSD>
            h.ParentStack(end)=[];
        end

        function results=getResults(h)
            results=[];
        end

        function b=stop(h,testObj)%#ok<INUSD>
            b=false;
        end
    end

    methods(Static)
        function b=isSimulationResult(resultObj)














            b=false;

            if isempty(resultObj)
                return;
            end





            if resultObj.Outcome==sltest.testmanager.TestResultOutcomes.Disabled
                b=true;
                return;
            end


            if~resultObj.RunOnTarget(1)

                simData=resultObj.SimulationMetadata;
                isSimModeKnown=~isempty(simData)...
                &&simData(1).simulationMode~="";

                if isSimModeKnown
                    if any(strcmpi(simData(1).simulationMode,...
                        ["normal","accelerator","rapid","rapid-accelerator"]))
                        b=true;
                    else
                        b=false;

                    end
                else
                    b=false;
                end
            end
        end
    end
end

