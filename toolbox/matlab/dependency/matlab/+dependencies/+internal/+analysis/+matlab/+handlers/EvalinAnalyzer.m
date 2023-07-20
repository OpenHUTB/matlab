classdef EvalinAnalyzer<dependencies.internal.analysis.matlab.FunctionAnalyzer




    properties(SetAccess=immutable)
        Functions="evalin";
        MinimumArguments=2;
        StringArguments=2;
        AllowedArguments=[];
    end

    methods

        function refs=analyze(~,analyzer,ref,factory)
            import dependencies.internal.analysis.matlab.handlers.checkBase;

            workspace=checkBase(analyzer,ref,factory);
            arg=ref.InputArguments(2);
            refs=analyzer.analyzeFragment(arg.Value,workspace,factory,arg.Line);
        end

    end

end
