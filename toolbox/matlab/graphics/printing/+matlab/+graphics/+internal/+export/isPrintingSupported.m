function supported=isPrintingSupported()



    import matlab.internal.lang.capability.Capability

    supported=Capability.isSupported(Capability.LocalClient);
end
