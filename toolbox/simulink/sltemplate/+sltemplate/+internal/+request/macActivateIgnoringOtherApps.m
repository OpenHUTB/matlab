function macActivateIgnoringOtherApps()




    import matlab.internal.lang.capability.Capability;

    if Capability.isSupported(Capability.LocalClient)&&ismac&&usejava('jvm')
        com.mathworks.util.NativeJava.macActivateIgnoringOtherApps;
    end
end
