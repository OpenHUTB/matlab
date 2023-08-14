function setStageDisplayReport(fileName,topModelName)





    stageName=DAStudio.message('Simulink:protectedModel:ProtectedModelReportMessageViewerStageName');
    stageObj=Simulink.output.Stage(stageName,'ModelName',topModelName,'UIMode',true);%#ok<NASGU>

    Simulink.ModelReference.ProtectedModel.displayReport(fileName);
end