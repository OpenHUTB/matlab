function utilAdjustCreateProject(mdladvObj,hDI)




    if~(hDI.isTurnkeyWorkflow||hDI.isGenericWorkflow||hDI.isXPCWorkflow)
        return;
    end

    hdlwaDriver=hdlwa.hdlwaDriver.getHDLWADriverObj;
    projectObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.CreateProject');


    inputParams=mdladvObj.getInputParameters(projectObj.MAC);
    projectDir=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputProjectFolder'));
    additionalSourceFiles=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputAdditionalSourceFiles'));
    additionalSourceFilesButton=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputAdd'));
    additionalTclFiles=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputAdditionalTclFiles'));
    additionalTclFilesButton=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputAdd2'));
    objective=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAObjective'));


    projectDir.Value=hDI.getProjectPath;
    additionalSourceFiles.Value=hDI.getCustomSourceFile;
    additionalTclFiles.Value=hDI.getCustomTclFile;
    objective.Value=hDI.getObjectiveName;





    projectDir.Enable=false;
    additionalSourceFiles.Enable=true;
    additionalTclFiles.Enable=true;
    additionalSourceFilesButton.Enable=true;
    additionalTclFilesButton.Enable=true;
    objective.Enable=true;


    if(strcmp(hDI.get('Tool'),'Xilinx ISE'))
        objective.Enable=false;
    elseif strcmp(hDI.get('Tool'),'Microchip Libero SoC')
        additionalSourceFiles.Enable=false;
        additionalSourceFilesButton.Enable=false;
        additionalTclFiles.Enable=false;
        additionalTclFilesButton.Enable=false;
        objective.Enable=false;
    else
    end

end

