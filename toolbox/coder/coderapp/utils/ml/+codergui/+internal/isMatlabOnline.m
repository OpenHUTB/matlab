function online=isMatlabOnline()


    import matlab.internal.lang.capability.Capability;
    online=~Capability.isSupported(Capability.LocalClient);
end