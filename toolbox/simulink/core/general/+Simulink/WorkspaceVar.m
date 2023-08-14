






function var=WorkspaceVar(varargin)


    MSLDiagnostic('Simulink:Data:WorkspaceVarObjectDeprecated').reportAsWarning;

    var=Simulink.VariableUsage(varargin{:});

