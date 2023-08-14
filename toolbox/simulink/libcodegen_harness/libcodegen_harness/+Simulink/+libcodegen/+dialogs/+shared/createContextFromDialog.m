function[status,msg,harnessStruct]=createContextFromDialog(dlgSrc)

    status=false;
    msg='';
    harnessStruct='';

    if dlgSrc.specifyInstance&&~exist(dlgSrc.instanceFileName,'file')
        msg=DAStudio.message('Simulink:LoadSave:FileNotFound',dlgSrc.instanceFileName);
        return;
    end

    if dlgSrc.specifyInstance&&dlgSrc.cutMap.isempty
        msg=DAStudio.message('Simulink:CodeContext:CodeContextFailedNoCompatibleBlocks',dlgSrc.instanceFileName,getfullname(dlgSrc.ownerH));
        return;
    end

    if~isempty(which(dlgSrc.codeContextName))&&...
        ~isequal(dlgSrc.codeContextName,bdroot)&&...
        isempty(find_system('SearchDepth',0,'type','block_diagram','Name',dlgSrc.codeContextName))
        warnStr=DAStudio.message('Simulink:CodeContext:WarnAboutNameShadowingOnCreation');
        title=DAStudio.message('Simulink:CodeContext:WarnAboutNameShadowingOnCreationTitle');
        choice=questdlg(warnStr,title,'Continue','Cancel','Continue');
        if~strcmp(choice,'Continue')
            msg=DAStudio.message('Simulink:CodeContext:CreationAbortedFileShadow');
            return;
        end
    end

    instancePath='';
    if dlgSrc.specifyInstance
        dlgSrc.cutName=dlgSrc.cutMap(dlgSrc.cutName);

        if~isempty(dlgSrc.instanceModelName)&&~isempty(dlgSrc.cutName)
            instancePath=dlgSrc.cutName;
        end
    end



    if~isempty(dlgSrc.ccInfo)

        close_system(dlgSrc.codeContextName,0);
        harnessStruct=Simulink.libcodegen.internal.rebuildCodeContext(dlgSrc.ownerH,dlgSrc.codeContextName,instancePath);
    else
        harnessStruct=Simulink.libcodegen.internal.createCodeContext(dlgSrc.ownerH,'InstancePath',instancePath,...
        'Name',dlgSrc.codeContextName,'Description',dlgSrc.harnessDescription,...
        'FromUI',true);
    end

    status=true;

end
