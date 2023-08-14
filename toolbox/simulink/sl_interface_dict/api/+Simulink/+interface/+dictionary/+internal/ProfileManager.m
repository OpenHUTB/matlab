classdef(Abstract)ProfileManager<handle





    methods(Abstract)
        profileName=getProfileName(this);
        profileFile=getProfileFilePath(this);
    end

    methods(Static)
        function manager=getManager(platformKind)
            switch(platformKind)
            case sl.interface.dict.mapping.PlatformMappingKind.AUTOSARClassic
                manager=autosar.dictionary.internal.ARClassicProfileManager();
            otherwise
                assert(false,'Only AUTOSARClassic is supported for platform profile');
            end
        end
    end
end


