function utilParseCreateProject(mdladvObj,hDI)




    inputParams=mdladvObj.getInputParameters('com.mathworks.HDL.CreateProject');
    projectDir=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputProjectFolder'));
    additionalSourceFiles=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputAdditionalSourceFiles'));
    additionalTclFiles=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputAdditionalTclFiles'));
    objective=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAObjective'));


    if~strcmp(projectDir.Value,hDI.getProjectPath)
        hDI.setProjectPath(projectDir.Value);
    end
    if~strcmp(additionalSourceFiles.Value,hDI.getCustomSourceFile)
        hDI.setCustomSourceFile(additionalSourceFiles.Value);
    end

    if~strcmp(additionalTclFiles.Value,hDI.getCustomTclFile)
        hDI.setCustomTclFile(additionalTclFiles.Value);
    end
    if~strcmp(objective.Value,hDI.getObjectiveName)
        hDI.setObjectiveFromName(objective.Value);
    end

end
