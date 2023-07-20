function notifyOutdatedProfile(mdlName)




    ZCStudio.makeZcFixitNotification(mdlName,'ProfileOutdated',...
    'SystemArchitecture:zcFixitWorkflows:ProfileOutdatedStudioNotification',...
    'warn');

end