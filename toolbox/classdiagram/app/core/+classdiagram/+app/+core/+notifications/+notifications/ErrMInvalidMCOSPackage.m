classdef ErrMInvalidMCOSPackage<classdiagram.app.core.notifications.notifications.DiagramNotification
    methods
        function obj=ErrMInvalidMCOSPackage(varargin)
            obj=obj@classdiagram.app.core.notifications.notifications.DiagramNotification(varargin{:});
            obj.Severity=classdiagram.app.core.notifications.Severity.Error;
            obj.Transient=false;
            obj.Target=struct('widgetId',"importDialog");
        end

        function createDiagnostic(obj,varargin)
            obj.Message=...
            classdiagram.app.core.notifications.notifications.makeCDVMessage('ErrMInvalidMCOSPackage',varargin{:});
        end
    end
end
