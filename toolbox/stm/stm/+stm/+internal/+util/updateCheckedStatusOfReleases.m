function updateCheckedStatusOfReleases(releaseNames,checked)







    rmgrInst=stm.internal.ReleaseMgrListener.getInstance();
    rmgrInst.detach();

    for idx=1:length(releaseNames)
        if strcmp(releaseNames{idx},getString(message('stm:MultipleReleaseTesting:CurrentRelease')))
            continue;
        end
        try
            Simulink.CoSimServiceUtils.updateReleaseCheckbox(releaseNames{idx},logical(checked{idx}));
        catch Mex %#ok<NASGU>
        end
    end

    rmgrInst.attach();
end
