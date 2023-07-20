function exportAllHarnesses(modelName,fromUI,hList)

    if fromUI&&~Simulink.harness.internal.showExportAllToIndependentModalAlert(modelName)
        return;
    end

    harnessConvertStage=Simulink.output.Stage(...
    DAStudio.message('Simulink:Harness:ExportHarnessStage'),...
    'ModelName',modelName,...
    'UIMode',fromUI);%#ok

    if nargin<3
        hList=Simulink.harness.internal.getHarnessList(modelName,'all');
    end

    isExternal=Simulink.harness.internal.isSavedIndependently(modelName);
    if~isExternal
        for i=1:numel(hList)

            if(exist(fullfile(pwd,[hList(i).name,'.slx']),'file')==4)
                DAStudio.error('Simulink:Harness:ExportToIndependentHarnessFileExistsError',hList(i).name,[hList(i).name,'.slx']);
            end
        end
    end

    origDirty=strcmpi(get_param(modelName,'Dirty'),'on');
    needsDirty=false;
    numHarnesses=numel(hList);
    for i=1:numHarnesses
        Simulink.harness.internal.export(hList(i).ownerFullPath,hList(i).name,true);


        if~isExternal&&~origDirty&&(i<numHarnesses)&&...
            (strcmpi(get_param(modelName,'Dirty'),'on'))
            set_param(modelName,'Dirty','off');
            needsDirty=true;
        end
    end

    if needsDirty
        set_param(modelName,'Dirty','on');
    end

    allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    studio=allStudios(1);
    editor=studio.App.getActiveEditor();
    editorName=editor.getName();

    editor=GLUE2.Util.findAllEditors(editorName);

    editor.deliverInfoNotification('Simulink:Harness:exportHarnesses',...
    DAStudio.message('Simulink:Harness:ExportToIndependentSuccessMsg',...
    modelName));
end

