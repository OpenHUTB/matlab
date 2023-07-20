classdef SimMechanicsAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        SimMechanicsVisualizationType=dependencies.internal.graph.Type("SimMechanicsVisualization");
    end

    methods

        function this=SimMechanicsAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createInstanceDataParameterQuery;

            queries.GraphicsFile=createInstanceDataParameterQuery('GraphicsFileName','SourceBlock','mblibv1/Bodies/Body');
            queries.ExtGeomSolid=createInstanceDataParameterQuery('ExtGeomFileName','SourceBlock','sm_lib/Body Elements/Solid');
            queries.ExtGeomFileSolid=createInstanceDataParameterQuery('ExtGeomFileName','SourceBlock','sm_lib/Body Elements/File Solid');
            queries.ReducedOrderFlexibleSolid=createInstanceDataParameterQuery('GeomFileName','SourceBlock',sprintf('sm_lib/Body Elements/Flexible Bodies/Reduced Order\nFlexible Solid'));

            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.graph.Component;
            files=[matches.GraphicsFile.Value,...
            matches.ExtGeomSolid.Value,...
            matches.ExtGeomFileSolid.Value,...
            matches.ReducedOrderFlexibleSolid.Value];

            blocks=[matches.GraphicsFile.BlockPath,...
            matches.ExtGeomSolid.BlockPath,...
            matches.ExtGeomFileSolid.BlockPath,...
            matches.ReducedOrderFlexibleSolid.BlockPath];

            deps=dependencies.internal.graph.Dependency.empty;
            for n=1:length(files)
                target=handler.Resolver.findFile(node,files{n},{});
                upComp=Component.createBlock(node,blocks{n},handler.getSID(blocks{n}));
                deps(n)=dependencies.internal.graph.Dependency.createSource(...
                upComp,target,this.SimMechanicsVisualizationType);
            end
        end

    end

end
