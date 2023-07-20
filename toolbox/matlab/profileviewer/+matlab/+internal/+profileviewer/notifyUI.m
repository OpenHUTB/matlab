function notifyUI(action,type)


    profileViewerService=matlab.internal.profileviewer.ProfileViewerService.getInstance(type);

    switch action
    case 'start'

        profileViewerService.notifyProfilerStart();
    case 'resume'

        profileViewerService.notifyProfilerResume();
    case 'stop'

        profileViewerService.notifyProfilerStop();
    case 'clear'

        profileViewerService.notifyProfilerClear();
    case 'viewer'

        profileViewerService.notifyProfileViewer();
    end
end
