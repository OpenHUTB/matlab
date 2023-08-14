classdef AllocationSetNodeAnalyzer<dependencies.internal.analysis.FileAnalyzer




    properties(Constant)
        SrcLinkType="AllocationSource"
        DstLinkType="AllocationTarget"
        Extensions=".mldatx";
    end

    methods

        function analyze=canAnalyze(this,handler,node)
            analyze=...
            canAnalyze@dependencies.internal.analysis.FileAnalyzer(this,handler,node)...
            &&dependencies.internal.analysis.sysarch.isAllocationSet(node.Location{1});
        end

        function deps=analyze(this,handler,node)
            deps=dependencies.internal.graph.Dependency.empty;


            allocSet=systemcomposer.allocation.load(node.Location{1});

            srcModel=allocSet.SourceModel.Name;
            dstModel=allocSet.TargetModel.Name;

            srcNode=handler.Resolver.findFile(node,srcModel,dependencies.internal.analysis.simulink.SimulinkNodeAnalyzer.Extensions);
            deps(end+1)=dependencies.internal.graph.Dependency(node,"",srcNode,"",this.SrcLinkType);

            dstNode=handler.Resolver.findFile(node,dstModel,dependencies.internal.analysis.simulink.SimulinkNodeAnalyzer.Extensions);
            deps(end+1)=dependencies.internal.graph.Dependency(node,"",dstNode,"",this.DstLinkType);
        end

    end

end
