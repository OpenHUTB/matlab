classdef ErrMNotSupported<classdiagram.app.core.notifications.notifications.DiagramNotification
    methods
        function obj=ErrMNotSupported(varargin)
            obj=obj@classdiagram.app.core.notifications.notifications.DiagramNotification(varargin{:});
            obj.Severity=classdiagram.app.core.notifications.Severity.Error;
            obj.Transient=false;
        end

        function createDiagnostic(obj,varargin)
            obj.Message=...
            classdiagram.app.core.notifications.notifications.makeCDVMessage('ErrMNotSupported',varargin{:});
        end
    end
end
