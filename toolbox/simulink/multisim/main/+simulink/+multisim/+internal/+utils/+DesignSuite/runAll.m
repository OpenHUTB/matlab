function runAll(modelHandle,designSuite)

    modelName=get_param(modelHandle,"Name");
    dvStageName=message("multisim:SetupGUI:DVMultiSimStageName").getString();
    dvStage=sldiagviewer.createStage(dvStageName,'ModelName',modelName);
    dvStageCleanup=onCleanup(@()delete(dvStage));

    try
        designStudies=designSuite.DesignStudies.toArray();
        selectedDesignStudies=designStudies([designStudies.SelectedForRun]);
        for designStudyToRun=selectedDesignStudies
            designStudyType=designStudyToRun.ParameterSpace.StaticMetaClass.name;
            out=simulink.multisim.internal.runner.("run"+designStudyType)(modelHandle,designStudyToRun);
            if isempty(out)
                continue;
            end


            returnWorkspaceOutputs=get_param(modelHandle,'ReturnWorkspaceOutputs');
            if returnWorkspaceOutputs==matlab.lang.OnOffSwitchState.on
                assignOutputToBase(modelHandle,out);
            end
            cvi.TopModelCov.genResultsForRunAll(modelHandle,designStudyToRun.Label);
        end
    catch ME
        MSLDiagnostic(ME).reportAsError();
    end
end

function assignOutputToBase(modelHandle,out)
    varName=get_param(modelHandle,'ReturnWorkspaceOutputsName');
    assignin('base',varName,out);
end