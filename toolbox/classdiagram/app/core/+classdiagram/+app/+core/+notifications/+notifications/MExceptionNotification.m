classdef MExceptionNotification<classdiagram.app.core.notifications.notifications.WDFNotification
    methods
        function obj=MExceptionNotification(varargin)
            obj=obj@classdiagram.app.core.notifications.notifications.WDFNotification(varargin{:});
            obj.Severity=classdiagram.app.core.notifications.Severity.Error;
            obj.Transient=false;
        end
    end
end
