classdef TargetInstallData<event.EventData




    properties
appName
    end

    methods
        function data=TargetInstallData(appName)
            data.appName=appName;
        end
    end
end
