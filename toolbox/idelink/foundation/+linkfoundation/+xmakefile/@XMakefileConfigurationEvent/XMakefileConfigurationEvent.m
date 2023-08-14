classdef XMakefileConfigurationEvent<event.EventData





    properties(Constant=true,Hidden=false)




        VALIDATE_REQUIRED_ENVIRONMENT='validate_required_environment';
        ARCHIVE_TARGET_BEFORE_BUILD='before_library_build';
        ARCHIVE_TARGET_AFTER_BUILD='after_library_build';
        EXECUTABLE_TARGET_BEFORE_BUILD='before_executable_build';
        EXECUTABLE_TARGET_AFTER_BUILD='after_executable_build';
        UNDEFINED_CONTEXT='undefined';




        DEBUG_BUILD_CONFIGURATION='Debug'
        RELEASE_BUILD_CONFIGURATION='Release';
        CUSTOM_BUILD_CONFIGURATION='CustomMW';
        UNDEFINED_BUILD_CONFIGURATION='Undefined';
    end

    properties(Access='public')
        Context='';
        BuildConfiguration='';
    end

    methods(Access='public')



        function eventData=XMakefileConfigurationEvent(context,cfg)

            if(1>nargin)
                context='';
            end
            if(2>nargin)
                cfg='';
            end
            if(isempty(context)),
                context=linkfoundation.xmakefile.XMakefileConfigurationEvent.UNDEFINED_CONTEXT;
            end
            if(isempty(cfg)),
                cfg=linkfoundation.xmakefile.XMakefileConfigurationEvent.UNDEFINED_BUILD_CONFIGURATION;
            end

            eventData.Context=context;
            eventData.BuildConfiguration=cfg;
        end
    end
end