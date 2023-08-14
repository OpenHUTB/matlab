function systemObjects=fpGetSupportedCppSystemObjects()


    if~isempty(which('coder.internal.getSystemObjectConstraints'))
        supportedMap=coder.internal.getSystemObjectConstraints;
        assert(isa(supportedMap,'containers.Map'));
        systemObjects=supportedMap.keys();
    else
        systemObjects={};
    end
end