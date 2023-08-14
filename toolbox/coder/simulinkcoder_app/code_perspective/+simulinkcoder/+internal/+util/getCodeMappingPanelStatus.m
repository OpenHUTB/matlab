function[status,msg]=getCodeMappingPanelStatus(studio)










    msg='';


    cp=simulinkcoder.internal.CodePerspective.getInstance;
    if~cp.isInPerspective(studio)
        status=0;
        return;
    end


    editor=studio.App.getActiveEditor;
    currentModelH=editor.blockDiagramHandle;
    cgb=get_param(currentModelH,'CodeGenBehavior');
    if strcmp(cgb,'None')
        status=0;
        return;
    end


    cp.init;
    task=cp.getTask('CodeMapping');


    studioModelH=studio.App.blockDiagramHandle;
    [studioApp,studioTarget]=cp.getInfo(studioModelH);
    studioCodeInterfacePackaging=get_param(studioModelH,'CodeInterfacePackaging');
    if~task.isAvailable(studioTarget)
        status=0;
        return;
    end


    editor=studio.App.getActiveEditor;
    currentModelH=editor.blockDiagramHandle;
    currentMdlName=get_param(currentModelH,'Name');
    [currentApp,currentTarget]=cp.getInfo(currentModelH);
    currentCodeInterfacePackaging=get_param(currentModelH,'CodeInterfacePackaging');


    if~task.isAvailable(currentTarget)
        status=0;
        msg=message(...
        'coderdictionary:mapping:CodeMappingsEditorNoMappings',...
        currentMdlName).getString;
        return;
    end


    if~strcmp(currentApp,studioApp)
        status=0;
        studioModelSTF=get_param(studioModelH,'SystemTargetFile');
        currentModelSTF=get_param(currentModelH,'SystemTargetFile');
        if~strcmp(currentCodeInterfacePackaging,studioCodeInterfacePackaging)&&...
            ~strcmp(studioModelSTF,currentModelSTF)
            msg=message(...
            'coderdictionary:mapping:CodeMappingsEditorInconsistentSTFandCIP',...
            currentMdlName,studioModelSTF,studioCodeInterfacePackaging).getString;
            return;
        elseif~strcmp(studioModelSTF,currentModelSTF)
            msg=message(...
            'coderdictionary:mapping:CodeMappingsEditorInconsistentMapping',...
            currentMdlName,studioModelSTF).getString;
            return;
        elseif~strcmp(currentCodeInterfacePackaging,studioCodeInterfacePackaging)
            msg=message(...
            'coderdictionary:mapping:CodeMappingsEditorInconsistentCIP',...
            currentMdlName,studioCodeInterfacePackaging).getString;
            return;
        else
            msg=message(...
            'coderdictionary:mapping:CodeMappingsEditorInconsistentApp',...
            currentMdlName).getString;
            return;
        end
    end


    if~strcmp(currentCodeInterfacePackaging,studioCodeInterfacePackaging)
        status=0;
        msg=message(...
        'coderdictionary:mapping:CodeMappingsEditorInconsistentCIP',...
        currentMdlName,studioCodeInterfacePackaging).getString;
        return;
    end


    currentModelMapping=Simulink.CodeMapping.getCurrentMapping(currentModelH);
    if isempty(currentModelMapping)
        status=1;
        msg=message(...
        'coderdictionary:mapping:CodeMappingsEditorMappingCreation',...
        currentMdlName).getString;
        return;
    end

    status=2;
end


