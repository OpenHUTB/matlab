function useWeb=useWebFrontEnd()





    valueFromsettings=settings().matlab.project.JsEnabled.ActiveValue;

    import matlab.internal.lang.capability.Capability
    isRemoteClient=~Capability.isSupported(Capability.LocalClient);

    isJSD=~isempty(getenv('Decaf'));

    useWeb=valueFromsettings||isRemoteClient||isJSD;

end