classdef RequirementSetNodeAnalyzer<dependencies.internal.analysis.FileAnalyzer




    properties(Constant)
        RequirementSetNodeAnalyzerType='RequirementInfo,RequirementSet';
        Extensions=".slreqx";
    end

    methods

        function deps=analyze(this,handler,node)
            import dependencies.internal.util.resolveExternalRequirementLinks;

            type=dependencies.internal.graph.Type(this.RequirementSetNodeAnalyzerType);
            deps=resolveExternalRequirementLinks(...
            handler,node,type,@(id,compNode)i_makeComponent(id,type,compNode));
        end

    end

end

function component=i_makeComponent(id,type,compNode)
    import dependencies.internal.graph.Component;
    if id==""
        component=Component.createRoot(compNode);
    else
        component=Component(compNode,id,type,0,"","","");
    end
end
