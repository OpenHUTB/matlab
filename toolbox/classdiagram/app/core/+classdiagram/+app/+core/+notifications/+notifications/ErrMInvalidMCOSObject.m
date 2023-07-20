classdef ErrMInvalidMCOSObject<classdiagram.app.core.notifications.notifications.DiagramNotification
    methods
        function obj=ErrMInvalidMCOSObject(varargin)
            obj=obj@classdiagram.app.core.notifications.notifications.DiagramNotification(varargin{:});
            obj.Severity=classdiagram.app.core.notifications.Severity.Error;
            obj.Transient=false;
            obj.Target=struct('widgetId',"importDialog");
        end

        function createDiagnostic(obj,varargin)
            obj.Message=...
            classdiagram.app.core.notifications.notifications.makeCDVMessage('ErrMInvalidMCOSObject',varargin{:});
        end
    end
end
