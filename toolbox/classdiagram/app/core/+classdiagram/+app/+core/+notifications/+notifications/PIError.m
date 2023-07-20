classdef PIError<classdiagram.app.core.notifications.notifications.DiagramNotification
    methods
        function obj=PIError(varargin)
            option=cell2struct(varargin,["a","b","c"],2);
            obj=obj@classdiagram.app.core.notifications.notifications.DiagramNotification(option);
            obj.Severity=classdiagram.app.core.notifications.Severity.Error;
            obj.Transient=true;
            obj.Target=struct('widgetId',"inspector");

            obj.UIMode=true;
            obj.CommandLineMode=false;
        end

        function createDiagnostic(obj,varargin)
            diagnosticInputs=struct2cell(varargin{:})';
            obj.Message=classdiagram.app.core.notifications.notifications.makeMessage(...
            diagnosticInputs{:});
        end
    end
end