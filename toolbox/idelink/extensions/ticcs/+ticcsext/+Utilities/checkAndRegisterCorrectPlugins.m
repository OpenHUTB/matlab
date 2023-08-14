function checkAndRegisterCorrectPlugins





    linkfoundation.autointerface.baselink.checkPlatformSupport(mfilename,...
    ticcsext.Utilities.getPlatformsSupported(),'ticcs');

    try
        registered=ticcsext.Utilities.checkifregistered;
        if(~registered)
            disp('Registering DLLs...');
            regretval=ticcsext.Utilities.registerplugins;
            if(regretval)
                disp([linkfoundation.util.getProductName,' successfully registered its plug-in for Code Composer Studio (CCS).']);
                disp('If CCS prompts you that "New components were detected," ');
                disp('click Yes or OK in the prompt dialog box to enable components');
                disp('for all compatible CCS installations.');
            else
                error(message('ERRORHANDLER:utils:CannotRegisterPlugins','TICCS'));
            end
        end
    catch regException
        if(strcmpi(regException.identifier,'CannotRegisterPlugins'))
            rethrow(regException);
        else
            nRegException=MException('TICCSEXT:util:CannotCheckAndRegisterPlugins',regException.message);
            throw(nRegException);
        end
    end


