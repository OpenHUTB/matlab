



function refresh_customizations()
    cm=DAStudio.CustomizationManager;
    cm.clearModelAdvisorCheckFcns;
    cm.clearModelAdvisorTaskFcns;
    cm.clearModelAdvisorProcessFcns;
    cm.clearModelAdvisorTaskAdvisorFcns;
    maroot=ModelAdvisor.Root;
    maroot.clear;
    am=Advisor.Manager.getInstance;
    am.clearSlCustomizationData;

    PrefFile=fullfile(prefdir,'mdladvprefs.mat');
    prefFileExist=exist(PrefFile,'file');
    if prefFileExist
        mdladvprefs=load(PrefFile);
        if isfield(mdladvprefs,'InstallConfiguration')
            mdladvprefs=rmfield(mdladvprefs,'InstallConfiguration');
            save(PrefFile,'-struct','mdladvprefs');
        end
    end
end