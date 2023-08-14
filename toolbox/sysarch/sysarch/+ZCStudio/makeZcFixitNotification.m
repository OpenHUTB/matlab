function makeZcFixitNotification(mdlName,notificationId,notificationMsg,type,varargin)





    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    editors=studios(1).App.getActiveEditor;

    messageId=strcat(mdlName,':',notificationId);

    switch notificationId
    case{'InvalidEnum','UnableToOpenInterfaceEditor'}
        assert(nargin==5);
        data=varargin{1};
        message=DAStudio.message(notificationMsg,mdlName,data);
    case 'ProfileOutdated'
        assert(nargin==4);
        message=DAStudio.message(notificationMsg,mdlName);
    end

    for editor=editors
        switch type
        case 'warn'
            editor.deliverWarnNotification(messageId,message);
        case 'info'
            editor.deliverInfoNotification(messageId,message);
        otherwise
            error('Invalid ''type'' specified: %s',type)
        end
    end
end
