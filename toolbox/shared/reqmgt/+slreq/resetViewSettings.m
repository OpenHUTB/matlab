









function resetViewSettings(target)
    vsm=slreq.app.MainManager.getInstance.getViewSettingsManager;

    if~isempty(vsm)
        vsm.resetFor(target);
    end
end

