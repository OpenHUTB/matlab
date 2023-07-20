function register(targetName,targetFolder)




    targetFolder=matlabshared.targetsdk.internal.getShortestEquivalentPath(targetFolder);
    registryFolder=fullfile(targetFolder,'registry');
    if isequal(exist(targetFolder,'dir'),7)&&isequal(exist(registryFolder,'dir'),7)
        disp(DAStudio.message('codertarget:targetapi:RegisteringTarget',targetName));
        addpath(targetFolder);
        addpath(registryFolder);
        rehash;
        if~isempty(ver('simulink'))
            sl_refresh_customizations;
        end
        disp(DAStudio.message('codertarget:targetapi:Done'));
    end
end