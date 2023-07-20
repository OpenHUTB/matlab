classdef WDFCommandNotification<classdiagram.app.core.notifications.notifications.DiagramNotification
    methods
        function obj=WDFCommandNotification(id,msg)
            obj=obj@classdiagram.app.core.notifications.notifications.DiagramNotification(msg);
            obj.Severity=classdiagram.app.core.notifications.Severity.Error;
            obj.Transient=false;

            obj.Category=id;
        end

        function createDiagnostic(obj,varargin)

            obj.Message=varargin{1};
        end
    end
end