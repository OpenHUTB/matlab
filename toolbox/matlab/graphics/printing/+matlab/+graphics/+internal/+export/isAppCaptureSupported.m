function supported=isAppCaptureSupported()






    import matlab.internal.lang.capability.Capability




    supported=~matlab.internal.environment.context.isWebAppServer&&...
    Capability.isSupported(Capability.LocalClient);

end