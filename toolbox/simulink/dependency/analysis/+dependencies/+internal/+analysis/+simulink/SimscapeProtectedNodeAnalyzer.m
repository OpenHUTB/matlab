classdef SimscapeProtectedNodeAnalyzer<dependencies.internal.analysis.FileAnalyzer




    properties(Constant)
        ProtectedSimscapeType='ProtectedSimscape';
        Extensions=".sscp";
    end

    methods

        function deps=analyze(this,handler,node)
            [folder,name]=fileparts(node.Location{1});
            source=handler.Resolver.findFile(node,fullfile(folder,name),".ssc");

            if source.Resolved
                deps=dependencies.internal.graph.Dependency.createDerived(...
                node,source,this.ProtectedSimscapeType);
            else
                deps=dependencies.internal.graph.Dependency.empty;
            end
        end

    end

end
