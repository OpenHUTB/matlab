function runGeneratedExecutable(bdH)





    model=get_param(bdH,'Name');

    h=DeploymentDiagram.getexplorer('name',model);
    if~isempty(h)
        h.setStatusMessage(DAStudio.message(...
        'Simulink:taskEditor:GenerateProfileRunExec'));
    end

    config=Simulink.fileGenControl('getConfig');
    codeGenFolder=config.CodeGenFolder;

    configSet=getActiveConfigSet(model);
    tmf=get_param(configSet,'TemplateMakefile');
    stf=get_param(configSet,'SystemTargetFile');

    exeFile='';

    if strcmp(tmf,'RTW.MSVCBuild')

        if strcmp(stf,'grt.tlc')
            codeGenFolder=[codeGenFolder,filesep,model,'_grt_rtw'];
        elseif strcmp(stf,'ert.tlc')
            codeGenFolder=[codeGenFolder,filesep,model,'_ert_rtw'];
        end

        if strcmpi(mexext,'mexw32')
            exeFile=fullfile(codeGenFolder,'msvc','Debug',model);
        elseif strcmpi(mexext,'mexw64')
            exeFile=fullfile(codeGenFolder,'msvc','x64','Debug',model);
        end
    else

        exeFile=[codeGenFolder,filesep,model];
    end

    exeFile=['"',exeFile,'"'];
    system(exeFile,'-echo');
end


