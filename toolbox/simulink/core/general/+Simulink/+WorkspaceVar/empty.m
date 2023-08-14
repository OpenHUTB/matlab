



function h=empty(varargin)


    MSLDiagnostic('Simulink:Data:WorkspaceVarObjectDeprecated').reportAsWarning;

    h=Simulink.VariableUsage.empty(varargin{:});
