function updateProfileViewer(type,profileFunction,functionName,profInfo)




    if nargin==2
        profileFunction('viewer');
        return;
    end
    status=profileFunction('status');
    isProfilerRunning=strcmp(status.ProfilerStatus,'on');
    if isProfilerRunning
        profileFunction('off');
    end
    profInfoStaleState=false;
    profileViewerService=matlab.internal.profileviewer.ProfileViewerService.getInstance(type);
    profileViewerService.notifyProfileViewer();
    if nargin==4
        profInfoStaleState=profileViewerService.isProfileInfoStale(profInfo);
        if profInfoStaleState
            profileViewerService.loadSavedProfileData(profInfo);
        end
    end

    profileViewerService.startServiceFromInputFunction(functionName,profInfoStaleState);
end