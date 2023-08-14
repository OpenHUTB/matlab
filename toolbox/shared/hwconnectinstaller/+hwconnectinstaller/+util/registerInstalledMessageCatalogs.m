function registerInstalledMessageCatalogs()




    try


        spRoot=matlabshared.supportpkg.internal.getSupportPackageRootNoCreate();
    catch

        return;
    end
    if isdir(fullfile(spRoot,'resources'))&&~isempty(spRoot)
        try
            matlab.internal.msgcat.setAdditionalResourceLocation(spRoot);
        catch ME
            warning(ME.identifier,'%s',ME.getReport);
        end

    end

end

