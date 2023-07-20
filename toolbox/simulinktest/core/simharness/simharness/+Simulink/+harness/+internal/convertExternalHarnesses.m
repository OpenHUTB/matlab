function convertExternalHarnesses(model,varargin)

    fromUI=false;
    forceNotification=false;
    if nargin>1
        fromUI=varargin{1};
    end
    if nargin>2
        forceNotification=varargin{2};
    end

    harnessConvertStage=Simulink.output.Stage(...
    DAStudio.message('Simulink:Harness:ConvertExternalHarnessesStage'),...
    'ModelName',get_param(model,'Name'),...
    'UIMode',fromUI);%#ok

    fileName=get_param(model,'FileName');
    [~,attrib]=fileattrib(fileName);
    if attrib.UserWrite~=1
        DAStudio.error('Simulink:Harness:ConvertOperationFailedFileNotWriteable',model,fileName);
    end

    if contains(fileName,'.mdl')
        DAStudio.error('Simulink:Harness:ConvertToInternalHarnessNotSupportedMDL',model);
    end

    hList=Simulink.harness.find(model);
    if isempty(hList)
        DAStudio.error('Simulink:Harness:NoHarnessExist');
    end

    if~Simulink.harness.internal.isSavedIndependently(model)
        DAStudio.error('Simulink:Harness:ConvertToInternalHarnessNotExternalError',model);
    end

    if Simulink.harness.internal.hasActiveHarness(model)
        DAStudio.error('Simulink:Harness:ConvertToInternalHarnessActiveHarnessError',model);
    end

    Simulink.harness.internal.checkFilesWritable(model,hList,'Convert External Harnesses',true);

    if fromUI&&~Simulink.harness.internal.showConvertToEmbeddedModalAlert(model)
        return;
    end

    try
        Simulink.harness.internal.closeHarnessDialogs(model);
        Simulink.harness.internal.setSavedIndependently(model,false);
        save_system(model);
        if fromUI||forceNotification
            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            studio=allStudios(1);
            editor=studio.App.getActiveEditor();
            editorName=editor.getName();

            editor=GLUE2.Util.findAllEditors(editorName);

            editor.deliverInfoNotification('Simulink:Harness:importExternal',...
            DAStudio.message('Simulink:Harness:ConvertToInternalHarnessSuccessMsg',...
            model));
        end
        if~fromUI

            Simulink.harness.internal.warn({'Simulink:Harness:ConvertToInternalHarnessWarning',model});
        end
    catch ME
        ME.throwAsCaller;
    end


end
