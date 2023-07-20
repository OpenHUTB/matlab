classdef PackagedModelAnalyzer<dependencies.internal.analysis.simulink.ModelAnalyzer




    properties(Constant)
        PackagedModelType='SimulinkCache';
    end

    methods

        function this=PackagedModelAnalyzer()
            this@dependencies.internal.analysis.simulink.ModelAnalyzer(true);
        end

        function deps=analyze(this,handler,node,~)
            [~,name]=fileparts(node.Location{1});
            package=handler.Resolver.findFile(node,name,{Simulink.packagedmodel.getPackagedModelExtension});

            if package.Resolved
                deps=dependencies.internal.graph.Dependency.createRuntime(...
                node,package,this.PackagedModelType);
            else
                deps=dependencies.internal.graph.Dependency.empty;
            end
        end

    end

end
