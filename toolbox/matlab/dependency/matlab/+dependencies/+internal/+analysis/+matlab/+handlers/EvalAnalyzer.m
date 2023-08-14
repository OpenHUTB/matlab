classdef EvalAnalyzer<dependencies.internal.analysis.matlab.FunctionAnalyzer




    properties(SetAccess=immutable)
        Functions=["eval","evalc","feval"];
        MinimumArguments=1;
        StringArguments=1;
        AllowedArguments=[];
    end

    methods

        function refs=analyze(~,analyzer,ref,factory)
            arg=ref.InputArguments(1);
            refs=analyzer.analyzeFragment(arg.Value,ref.Workspace,factory,arg.Line);
        end

    end

end
