classdef ProtectedModelAnalyzer<dependencies.internal.analysis.FileAnalyzer




    properties(Constant)
        ProtectDerivedType='ProtectedModel';
        Extensions=[".mdlp",".slxp"];
    end

    methods

        function deps=analyze(this,handler,node)

            [~,name]=fileparts(node.Location{1});
            slxSource=handler.Resolver.findFile(node,name,".slx");
            mdlSource=handler.Resolver.findFile(node,name,".mdl");


            if slxSource.Resolved&&mdlSource.Resolved
                key="SimulinkDependencyAnalysis:Engine:MultipleRefModelSrcFiles";
                warning=dependencies.internal.graph.Warning(...
                key,message(key,name).getString,"",this.ProtectDerivedType);
                handler.warning(warning);
            end

            if slxSource.Resolved
                deps=dependencies.internal.graph.Dependency.createDerived(...
                node,slxSource,this.ProtectDerivedType);
            elseif mdlSource.Resolved
                deps=dependencies.internal.graph.Dependency.createDerived(...
                node,mdlSource,this.ProtectDerivedType);
            else
                deps=dependencies.internal.graph.Dependency.empty;
            end

        end
    end

end
