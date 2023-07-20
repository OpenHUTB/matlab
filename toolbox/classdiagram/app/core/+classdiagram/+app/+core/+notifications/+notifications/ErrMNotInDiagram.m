classdef ErrMNotInDiagram<classdiagram.app.core.notifications.notifications.DiagramNotification
    methods
        function obj=ErrMNotInDiagram(varargin)
            obj=obj@classdiagram.app.core.notifications.notifications.DiagramNotification(varargin{:});
            obj.Severity=classdiagram.app.core.notifications.Severity.Error;
            obj.Transient=false;
        end

        function createDiagnostic(obj,varargin)
            obj.Message=...
            classdiagram.app.core.notifications.notifications.makeCDVMessage('ErrMNotInDiagram',varargin{:});
        end
    end
end
