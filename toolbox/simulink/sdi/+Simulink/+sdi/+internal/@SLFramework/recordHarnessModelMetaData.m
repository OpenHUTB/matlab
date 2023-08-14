function recordHarnessModelMetaData(~,obj,mdlName,runID)




    try

        isHarness=Simulink.sdi.internal.SLUtil.isHarnessModel(mdlName);


        if isHarness

            testUnitMdl=Simulink.sdi.internal.SLUtil.findTestUnitBlock(mdlName);
            testUnitMdl=get_param(testUnitMdl,'ModelName');
            metaData.testUnit.name=testUnitMdl;
            metaData.testUnit.version=get_param(testUnitMdl,'ModelVersion');
            metaData.testUnit.modified=get_param(testUnitMdl,'LastModifiedDate');
            metaData.testUnit.solverType=get_param(testUnitMdl,'SolverType');
            metaData.testUnit.solverName=get_param(testUnitMdl,'SolverName');
            metaData.testUnit.fixedStep=get_param(testUnitMdl,'FixedStep');


            metaData.testHarness.name=mdlName;
            metaData.testHarness.version=get_param(mdlName,'ModelVersion');
            metaData.testHarness.modified=get_param(mdlName,'LastModifiedDate');
            metaData.testHarness.solverType=get_param(mdlName,'SolverType');
            metaData.testHarness.solverName=get_param(mdlName,'SolverName');
            metaData.testHarness.fixedStep=get_param(mdlName,'FixedStep');


            obj.setRunHarnessModelMetaData(runID,metaData)
        end
    catch ME %#ok

    end
end