classdef RequirementLinkSetNodeAnalyzer<dependencies.internal.analysis.FileAnalyzer




    properties(Constant)
        RequirementLinkSetNodeAnalyzerType='RequirementInfo,LinkSet';
        Extensions=[".slmx",".req"];
    end

    methods

        function deps=analyze(this,handler,node)
            filename=node.Location{1};
            set=slreq.find("type","LinkSet","Filename",filename);
            if isempty(set)

                [~,name,ext]=fileparts(filename);
                if strcmp(ext,".req")
                    set=slreq.find("type","LinkSet","name",name);
                end
            end

            if isempty(set)

                set=slreq.load(filename);
                cleanup=onCleanup(@()slreq.discardLinkSet(set.Artifact));
            end

            artNode=handler.Resolver.findFile(node,set.Artifact,{});
            if artNode.Resolved
                deps=dependencies.internal.graph.Dependency(...
                artNode,"",node,"",this.RequirementLinkSetNodeAnalyzerType);
            else
                deps=dependencies.internal.graph.Dependency.empty;
            end
        end

    end

end
