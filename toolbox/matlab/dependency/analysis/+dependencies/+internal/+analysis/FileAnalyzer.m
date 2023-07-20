classdef(Abstract)FileAnalyzer<dependencies.internal.analysis.NodeAnalyzer





    properties(GetAccess=private,SetAccess=immutable)
        Filter(1,1)dependencies.internal.graph.NodeFilter;
    end

    methods

        function this=FileAnalyzer
            this.Filter=dependencies.internal.graph.NodeFilter.fileExists(this.Extensions);
        end

        function analyze=canAnalyze(this,~,node)
            analyze=apply(this.Filter,node);
        end

    end

end

