function checkIfPlatformIsSupported(unsupportedFile)
    import matlab.internal.lang.capability.Capability;

    if~Capability.isSupported(Capability.LocalClient)
        productName=connector.internal.getProductNameByClientType;
        error(message('gpucoder:system:gpucoder_fcn_not_supp_platform',unsupportedFile,productName));
    end

end