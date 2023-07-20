function bool=isMOTW()




    import matlab.internal.lang.capability.Capability;
    bool=~Capability.isSupported(Capability.LocalClient);
end
