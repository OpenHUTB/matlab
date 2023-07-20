classdef PCodeNodeAnalyzer<dependencies.internal.analysis.FileAnalyzer




    properties(Constant)
        PCodeDerivedType='PCode';
        Extensions=".p";
    end

    methods

        function deps=analyze(this,~,node)
            deps=dependencies.internal.graph.Dependency.empty;

            mNode=dependencies.internal.analysis.findSource(node,".m");
            if mNode.Resolved
                deps(end+1)=dependencies.internal.graph.Dependency.createDerived(...
                node,mNode,this.PCodeDerivedType);
            end
        end

    end

end
