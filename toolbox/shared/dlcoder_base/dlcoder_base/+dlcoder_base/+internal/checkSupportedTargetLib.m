function checkSupportedTargetLib(targetLibrary,DLmexAcceleration)






    if~DLmexAcceleration
        supportedLibraries=dlcoder_base.internal.getSupportedTargetLibs();
        supportedLibraryString=dlcoder_base.internal.getSupportedLibraryString(supportedLibraries);

        targetLibrary=lower(convertStringsToChars(targetLibrary));

        if isempty(targetLibrary)

            error(message('gpucoder:cnnconfig:empty_target_lib',...
            getString(message('gpucoder:cnnconfig:InvalidInputForDeepLearningConfig')),...
            getString(message('gpucoder:cnnconfig:ValidDeepLearningTargets',supportedLibraryString))));

        elseif~any(strcmpi(targetLibrary,supportedLibraries))
            error(message('gpucoder:cnnconfig:unsupported_target_lib',targetLibrary,supportedLibraryString));
        end
    end
end
