classdef ErrMInvalidMCOSClass<classdiagram.app.core.notifications.notifications.DiagramNotification
    methods
        function obj=ErrMInvalidMCOSClass(varargin)
            obj=obj@classdiagram.app.core.notifications.notifications.DiagramNotification(varargin{:});
            obj.Severity=classdiagram.app.core.notifications.Severity.Error;
            obj.Transient=false;
            obj.Target=struct('widgetId',"importDialog");
        end

        function createDiagnostic(obj,varargin)
            obj.Message=...
            classdiagram.app.core.notifications.notifications.makeCDVMessage('ErrMInvalidMCOSClass',varargin{:});
        end
    end
end
