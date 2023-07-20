classdef CommentsAnalyzer<dependencies.internal.analysis.simulink.ModelAnalyzer




    properties(Constant)
        CommentsType='Comments';
    end

    methods

        function this=CommentsAnalyzer()
            this@dependencies.internal.analysis.simulink.ModelAnalyzer(true);
        end

        function deps=analyze(this,handler,node,~)
            deps=dependencies.internal.graph.Dependency.empty;

            folder=fileparts(node.Path);
            path=fullfile(folder,handler.ModelInfo.BlockDiagramName+"_comments.mldatx");

            target=handler.Resolver.findFile(node,path,".mldatx");
            if target.Resolved
                deps=dependencies.internal.graph.Dependency(...
                node,"",target,"",this.CommentsType);
            end
        end

    end

end
