function defaultFolder=getDefaultFolder





    import matlab.internal.lang.capability.Capability

    creationSettings=settings().matlab.project.creation;
    if Capability.isSupported(Capability.LocalClient)
        defaultFolder=creationSettings.DefaultFolder.ActiveValue;
    else
        defaultFolder=creationSettings.MODefaultFolder.ActiveValue;
    end

end

