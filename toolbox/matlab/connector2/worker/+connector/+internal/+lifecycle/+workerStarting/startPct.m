

function startPct()
    if~isempty(which('parallel.internal.settings.setMATLABOnlineDefaultSettings'))
        parallel.internal.settings.setMATLABOnlineDefaultSettings();
    end

    if~isempty(which('parallel.internal.settings.getFactoryProfileNames'))

        parallel.internal.settings.getFactoryProfileNames();
    end
end
