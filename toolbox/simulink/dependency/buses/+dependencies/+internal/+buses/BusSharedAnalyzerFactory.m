classdef BusSharedAnalyzerFactory<dependencies.internal.analysis.SharedAnalyzerFactory




    properties(Constant)
        Name="Bus";
    end

    properties(SetAccess=immutable)
BusNode
    end

    methods
        function this=BusSharedAnalyzerFactory(node)
            this.BusNode=node;
        end

        function sharedAnalyzer=create(this)
            sharedAnalyzer=dependencies.internal.buses.BusSharedAnalyzer(this.BusNode);
        end
    end

end
