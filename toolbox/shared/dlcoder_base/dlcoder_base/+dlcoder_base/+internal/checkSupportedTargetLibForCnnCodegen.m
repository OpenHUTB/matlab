function checkSupportedTargetLibForCnnCodegen(targetLibrary)




    import matlab.internal.lang.capability.Capability

    supportedLibrary="arm-compute-mali";

    targetLibrary=lower(convertStringsToChars(targetLibrary));


    if isempty(targetLibrary)

        error(message('gpucoder:cnnconfig:empty_target_lib_cnncodegen',supportedLibrary));
    elseif~strcmpi(targetLibrary,supportedLibrary)

        error(message('gpucoder:cnnconfig:unsupported_target_lib_cnncodegen',targetLibrary,supportedLibrary));
    end

    if~Capability.isSupported(Capability.LocalClient)

        error(message('gpucoder:cnnconfig:unsupported_cnncodegen_remote'));
    end

end
