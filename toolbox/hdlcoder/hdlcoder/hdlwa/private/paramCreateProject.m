function paramCreateProject(taskobj)



    mdladvObj=taskobj.MAObj;


    system=mdladvObj.System;
    hModel=bdroot(system);
    hDriver=hdlmodeldriver(hModel);
    hDI=hDriver.DownstreamIntegrationDriver;
    if hDI.hAvailableToolList.isToolListEmpty
        error(message('hdlcoder:workflow:NoAvailableTool'));
    end


    inputParams=mdladvObj.getInputParameters(taskobj.MAC);
    projectDir=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputProjectFolder'));
    additionalSourceFile=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputAdditionalSourceFiles'));
    additionalTclFile=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputAdditionalTclFiles'));
    objective=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAObjective'));


    try
        updateParameterName='';
        if~strcmp(projectDir.Value,hDI.getProjectPath)
            updateParameterName='projectDir';
            hDI.setProjectPath(projectDir.Value);
        elseif~strcmp(additionalSourceFile.Value,hDI.getCustomSourceFile)
            updateParameterName='additionalSourceFiles';
            hDI.setCustomSourceFile(additionalSourceFile.Value);
        elseif~strcmp(additionalTclFile.Value,hDI.getCustomTclFile)
            updateParameterName='additionalTclFiles';
            hDI.setCustomTclFile(additionalTclFile.Value);
        elseif~strcmp(objective.Value,hDI.getObjectiveName)
            updateParameterName='objective';
            hDI.setObjectiveFromName(objective.Value);
        end
    catch ME
        hf=errordlg(ME.message,'Error','modal');

        set(hf,'tag','HDL Workflow Advisor error dialog');
        setappdata(hf,'MException',ME);


        uiwait(hf);


        hMAExplorer=mdladvObj.MAExplorer;
        if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
            currentDialog=hMAExplorer.getDialog;
            if strcmpi(updateParameterName,'projectDir')
                currentDialog.setWidgetValue('InputParameters_1',hDI.getProjectPath);
            elseif strcmpi(updateParameterName,'objective')
                currentDialog.setWidgetValue('InputParameters_2',getIndexNumber(hDI.getObjectiveName,hDI.Objective.getObjectiveList));
            elseif strcmpi(updateParameterName,'additionalSourceFiles')
                currentDialog.setWidgetValue('InputParameters_3',hDI.getCustomSourceFile);
            elseif strcmpi(updateParameterName,'additionalTclFiles')
                currentDialog.setWidgetValue('InputParameters_5',hDI.getCustomTclFile);
            end
        end
    end


    utilAdjustCreateProject(mdladvObj,hDI);

end

