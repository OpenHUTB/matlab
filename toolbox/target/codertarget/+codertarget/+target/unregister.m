function unregister(targetName,targetFolder)





    registryFolder=fullfile(targetFolder,'registry');
    if codertarget.target.isTargetRegistered(targetName)
        disp(DAStudio.message('codertarget:targetapi:UnregisteringTarget',targetName));
        rmpath(targetFolder);
        rmpath(registryFolder);
        rehash;
        if~isempty(ver('simulink'))
            sl_refresh_customizations;
        end
        disp(DAStudio.message('codertarget:targetapi:Done'));
    end
end