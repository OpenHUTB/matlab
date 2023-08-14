classdef SettingsToRestore<handle

    properties
        defaultTarget=[];
        stopTime=[];
        application=[];
    end

    methods
        function restoreSettings(self)
            stm.internal.genericrealtime.FollowProgress.progress('begin: SettingsToRestore.restoreSettings()');
            if~isempty(self.defaultTarget)
                tgs=slrealtime.Targets;
                target_object_name=tgs.getDefaultTargetName;
                if~strcmpi(target_object_name,self.defaultTarget)
                    tgs.setDefaultTargetName(self.defaultTarget);
                end
            end
            stm.internal.genericrealtime.FollowProgress.progress('end: SettingsToRestore.restoreSettings()');
        end

        function restoreStopTime(self)

            self.stopTime=[];
        end


    end

end
