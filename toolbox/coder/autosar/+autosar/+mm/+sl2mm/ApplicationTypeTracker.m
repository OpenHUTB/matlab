classdef ApplicationTypeTracker<handle





    properties(Access=private)
        AppTypeNames;
        ModeGroupNames;
    end

    methods(Access=public)
        function addAppTypeName(this,appTypeName)
            this.AppTypeNames{end+1}=appTypeName;
        end

        function appTypeNames=getAppTypeNames(this)
            appTypeNames=unique(this.AppTypeNames);
        end

        function addModeGroupName(this,modeGroupName)
            this.ModeGroupNames{end+1}=modeGroupName;
        end

        function modeGroupNames=getModeGroupNames(this)
            modeGroupNames=unique(this.ModeGroupNames);
        end
    end
end
