classdef BaseWorkspaceAnalyzer<dependencies.internal.analysis.NodeAnalyzer




    properties(Access=private)
        Initialized=false;
    end

    properties(Constant)
        Extensions=string.empty;
    end

    methods

        function analyze=canAnalyze(this,handler,~)
            analyze=false;
            if~this.Initialized
                vars=evalin('base','who');
                handler.Analyzers.MATLAB.BaseWorkspace.addVariables(vars);
                this.Initialized=true;
            end
        end

        function deps=analyze(~,~,~)
            deps=dependencies.internal.graph.Dependency.empty;
        end

    end

end
