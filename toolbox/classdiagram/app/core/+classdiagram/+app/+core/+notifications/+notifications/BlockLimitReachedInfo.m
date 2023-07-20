classdef BlockLimitReachedInfo<classdiagram.app.core.notifications.notifications.DiagramNotification
    methods
        function obj=BlockLimitReachedInfo(numClasses,~)
            obj=obj@classdiagram.app.core.notifications.notifications.DiagramNotification(numClasses);
            obj.Transient=false;
        end

        function createDiagnostic(obj,numClasses)
            obj.Message=classdiagram.app.core.notifications.notifications.makeCDVMessage(...
            'InfoBlockLimitReached',string(numClasses));
        end
    end
end
