classdef EMLAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        MATLABFcnType='MATLABFcn';
        StateflowMATLABFcnType='StateflowMATLABFcn';
    end

    methods

        function this=EMLAnalyzer()
            import dependencies.internal.analysis.simulink.queries.StateflowQuery
            import dependencies.internal.analysis.simulink.queries.StateflowChartQuery

            queries.eml=StateflowQuery.createStateQuery("eml/script");
            queries.mlfunc=StateflowChartQuery.createChartQuery(type="EML_CHART");

            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.graph.Component;
            import dependencies.internal.graph.Type;

            deps=dependencies.internal.graph.Dependency.empty;


            if isempty(matches.eml)
                return;
            end


            emlChartIDs=string([matches.eml.ChartID]);
            simChartIDs=string([matches.mlfunc.ChartID]);
            simIdx=ismember(emlChartIDs,simChartIDs);


            for eml=matches.eml(simIdx)
                code=eml.Value;

                blockPath=handler.getStateflowChartName(eml.ChartID);
                blockComp=Component.createBlock(node,blockPath,handler.getSID(blockPath));
                workspace=handler.getStateflowWorkspace(eml.ID);

                emlDeps=i_analyze(handler,node,blockComp,this.MATLABFcnType,code,workspace);
                deps=[deps,emlDeps];%#ok<AGROW>


                for m=1:length(emlDeps)
                    [~,name,ext]=fileparts(emlDeps(m).DownstreamNode.Location{1});
                    if strcmp(ext,['.',mexext])
                        mcode=handler.Resolver.findFile(node,[name,'.m'],{});
                        if mcode.Resolved
                            deps(end+1)=dependencies.internal.graph.Dependency.createSource(...
                            emlDeps(m).UpstreamComponent,mcode,Type(this.MATLABFcnType));%#ok<AGROW>
                        end
                    end
                end
            end


            for eml=matches.eml(~simIdx)
                code=eml.Value;

                blockComp=eml.createComponent();
                workspace=handler.getStateflowWorkspace(eml.ID);

                deps=[deps,i_analyze(handler,node,blockComp,this.StateflowMATLABFcnType,code,workspace)];%#ok<AGROW>
            end
        end

    end

end


function deps=i_analyze(handler,node,component,type,fragment,workspace)


    fragment=strrep(fragment,'eml.extrinsic','eval');


    factory=dependencies.internal.analysis.DependencyFactory(handler,component,type);
    deps=handler.Analyzers.MATLAB.analyze(fragment,factory,workspace);

end
