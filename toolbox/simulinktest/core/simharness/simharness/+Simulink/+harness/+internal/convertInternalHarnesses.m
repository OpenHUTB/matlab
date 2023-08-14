function convertInternalHarnesses(model,varargin)

    fromUI=false;
    forceNotification=false;
    if nargin>1
        fromUI=varargin{1};
    end
    if nargin>2
        forceNotification=varargin{2};
    end

    harnessConvertStage=Simulink.output.Stage(...
    DAStudio.message('Simulink:Harness:ConvertInternalHarnessesStage'),...
    'ModelName',get_param(model,'Name'),...
    'UIMode',fromUI);%#ok

    fileName=get_param(model,'FileName');
    if isempty(fileName)
        DAStudio.error('Simulink:Harness:ConvertToExternalHarnessNotSavedError',model);
    end

    [~,attrib]=fileattrib(fileName);
    if attrib.UserWrite~=1
        DAStudio.error('Simulink:Harness:ConvertOperationFailedFileNotWriteable',model,fileName);
    end

    hList=Simulink.harness.find(model);
    if isempty(hList)
        DAStudio.error('Simulink:Harness:NoHarnessExist');
    end

    if Simulink.harness.internal.isSavedIndependently(model)
        DAStudio.error('Simulink:Harness:ConvertToExternalHarnessNotInternalError',model);
    end

    if Simulink.harness.internal.hasActiveHarness(model)
        DAStudio.error('Simulink:Harness:ConvertToExternalHarnessActiveHarnessError',model);
    end

    [path,~,~]=fileparts(fileName);
    [~,attrib]=fileattrib(path);
    if~attrib.UserWrite
        DAStudio.error('Simulink:Harness:ExternalHarnessDirNotWritable',hList(1).name,path);
    end



    [~,attrib]=fileattrib(pwd);
    if~attrib.UserWrite
        DAStudio.error('Simulink:Harness:ExternalHarnessFileNotWritable',hList(1).name,[hList(1).name,'.slx']);
    end

    for i=1:numel(hList)

        if(exist(fullfile(pwd,[hList(i).name,'.slx']),'file')==4)
            DAStudio.error('Simulink:Harness:ConvertToExternalHarnessFileExistsError',hList(i).name,[hList(i).name,'.slx']);
        end
    end

    if fromUI&&~Simulink.harness.internal.showConvertToExternalModalAlert(model)
        return;
    end

    try
        Simulink.harness.internal.closeHarnessDialogs(model);
        save_system(model);
        Simulink.harness.internal.setSavedIndependently(model,true);
        save_system(model);
        if fromUI||forceNotification
            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            studio=allStudios(1);
            editor=studio.App.getActiveEditor();
            editorName=editor.getName();

            editor=GLUE2.Util.findAllEditors(editorName);

            editor.deliverInfoNotification('Simulink:Harness:exportInternal',...
            DAStudio.message('Simulink:Harness:ConvertToExternalHarnessSuccessMsg',...
            model));
        end
        if~fromUI

            Simulink.harness.internal.warn({'Simulink:Harness:ConvertToExternalHarnessWarning',model});
        end
    catch ME
        ME.throwAsCaller;
    end


end
