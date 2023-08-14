function notify=getMatlabUINotificationPolicy(action)




    switch action
    case "clear"
        notify=true;
    case "start"
        notify=true;
    case "stop"
        notify=true;
    case "resume"
        notify=true;
    otherwise
        error(['Action ',action,' invalid.'])
    end
end
