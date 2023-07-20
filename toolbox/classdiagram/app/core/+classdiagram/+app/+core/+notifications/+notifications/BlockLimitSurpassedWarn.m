classdef BlockLimitSurpassedWarn<classdiagram.app.core.notifications.notifications.DiagramNotification
    methods
        function obj=BlockLimitSurpassedWarn(varargin)
            option=cell2struct(varargin,["a","b","c"],2);
            obj=obj@classdiagram.app.core.notifications.notifications.DiagramNotification(option);
            obj.Transient=false;
        end

        function createDiagnostic(obj,varargin)
            diagnosticInputs=struct2cell(varargin{:})';
            obj.Message=classdiagram.app.core.notifications.notifications.makeCDVMessage(...
            'InfoBlockLimitReached1',diagnosticInputs{:});
        end
    end
end
