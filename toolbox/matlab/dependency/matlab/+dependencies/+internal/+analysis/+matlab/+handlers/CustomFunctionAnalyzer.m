classdef CustomFunctionAnalyzer<dependencies.internal.analysis.matlab.FunctionAnalyzer




    properties(SetAccess=immutable)
        Functions=[];
        MinimumArguments=0;
        StringArguments=[];
        AllowedArguments=[];
    end

    properties(Access=private)
        Analyzer;
    end

    methods

        function this=CustomFunctionAnalyzer(analyzer,func,minArgs,strings,allowed)
            this.Analyzer=analyzer;
            this.Functions={func};
            if nargin>2
                this.MinimumArguments=minArgs;
            end
            if nargin>3
                this.StringArguments=strings;
            end
            if nargin>4
                this.AllowedArguments=allowed;
            end
        end

        function refs=analyze(this,analyzer,ref,factory)
            refs=this.Analyzer(analyzer,ref,factory);
        end

    end

end
