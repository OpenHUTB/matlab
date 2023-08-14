classdef BusSharedAnalyzer<dependencies.internal.analysis.SharedAnalyzer




    properties(Constant)
        Name="Bus";
    end

    properties(SetAccess=immutable)
BusNode
    end

    methods
        function this=BusSharedAnalyzer(node)
            this.BusNode=node;
        end

        function deps=finalize(~)
            deps=dependencies.internal.graph.Dependency.empty;
        end
    end

end
