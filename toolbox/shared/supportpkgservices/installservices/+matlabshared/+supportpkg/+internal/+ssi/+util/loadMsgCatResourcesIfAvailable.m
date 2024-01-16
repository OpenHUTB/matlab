function loadMsgCatResourcesIfAvailable(spRoot)

    validateattributes(spRoot,{'char'},{'nonempty'});
    if isdir(fullfile(spRoot,'resources'))
        try
            matlab.internal.msgcat.setAdditionalResourceLocation(spRoot);
        catch
        end
    end
end