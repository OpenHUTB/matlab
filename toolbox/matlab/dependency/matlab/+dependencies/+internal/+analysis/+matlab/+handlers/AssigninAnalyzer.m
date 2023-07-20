classdef AssigninAnalyzer<dependencies.internal.analysis.matlab.FunctionAnalyzer




    properties(SetAccess=immutable)
        Functions="assignin";
        MinimumArguments=2;
        StringArguments=2;
        AllowedArguments=[];
    end

    methods

        function refs=analyze(~,analyzer,ref,factory)
            import dependencies.internal.analysis.matlab.handlers.checkBase;

            refs=dependencies.internal.analysis.matlab.Reference.empty;

            workspace=checkBase(analyzer,ref,factory);
            variable=ref.InputArguments(2).Value;
            workspace.addVariables({variable});
        end

    end

end
