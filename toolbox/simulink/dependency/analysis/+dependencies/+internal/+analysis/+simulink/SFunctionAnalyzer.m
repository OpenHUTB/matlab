classdef SFunctionAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        SFunctionType=dependencies.internal.graph.Type("SFunction");
        MSFunctionType=dependencies.internal.graph.Type("MSFunction");
        RTWMakeConfigType=dependencies.internal.graph.Type("RTWMakeConfig");
        MexDerivedType='Mex';
    end

    methods

        function this=SFunctionAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createParameterQuery
            import dependencies.internal.analysis.simulink.queries.StateflowChartQuery.createChartQuery

            queries.sfunc=createParameterQuery("FunctionName",BlockType="S-Function");
            queries.msfunc=createParameterQuery("FunctionName",BlockType="M-S-Function");
            queries.emlCharts=createChartQuery(type="EML_CHART");

            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.graph.Component;
            import dependencies.internal.graph.Dependency;

            deps=Dependency.empty(1,0);


            sfunctions=matches.sfunc.Value;
            sfunctionPaths=matches.sfunc.BlockPath;
            msfunctions=matches.msfunc.Value;
            msfunctionPaths=matches.msfunc.BlockPath;
            emlPaths=string(arrayfun(@(m)handler.getStateflowChartName(m.ChartID),matches.emlCharts));


            nonempty=~cellfun('isempty',sfunctions);


            eml=startsWith(sfunctionPaths,emlPaths);


            for m=find(nonempty&~eml)
                sfunction=sfunctions{m};
                componentPath=sfunctionPaths{m};
                component=Component.createBlock(node,componentPath,handler.getSID(componentPath));


                binaryNode=i_getBinaryNode(handler,node,sfunction);
                sfunNodes=[
                handler.Resolver.findFile(node,sfunction,".c")
                handler.Resolver.findFile(node,sfunction,".cpp")
                ];


                deps(end+1)=Dependency.createRuntime(...
                component,binaryNode,this.SFunctionType);%#ok<AGROW>
                if binaryNode.Resolved
                    path=fileparts(binaryNode.Location{1});
                    rtwNode=handler.Resolver.findFile(node,fullfile(path,'rtwmakecfg'),".m");

                    if rtwNode.Resolved
                        deps(end+1)=Dependency.createSource(...
                        component,rtwNode,...
                        this.RTWMakeConfigType);%#ok<AGROW>
                    end
                end


                for n=1:length(sfunNodes)
                    sfunNode=sfunNodes(n);
                    if sfunNode.Resolved&&sfunNode.isFile()

                        deps(end+1)=Dependency.createSource(...
                        component,sfunNode,...
                        this.SFunctionType);%#ok<AGROW>


                        deps(end+1)=Dependency.createDerived(...
                        binaryNode,sfunNode,this.MexDerivedType);%#ok<AGROW>
                        path=fileparts(sfunNode.Location{1});
                        rtwNode=handler.Resolver.findFile(node,fullfile(path,'rtwmakecfg'),".m");

                        if rtwNode.Resolved
                            deps(end+1)=Dependency.createSource(...
                            component,rtwNode,...
                            this.RTWMakeConfigType);%#ok<AGROW>
                        end
                    end
                end


                if sum([sfunNodes.Resolved])>1
                    key='SimulinkDependencyAnalysis:Engine:MultipleSFunSrcFiles';
                    warning=dependencies.internal.graph.Warning(...
                    key,message(key,sfunction).getString,componentPath,this.SFunctionType.ID);
                    handler.warning(warning);
                end


                tlcNode=handler.Resolver.findFile(node,sfunction,".tlc");
                if~tlcNode.Resolved&&binaryNode.Resolved

                    [pp,ff]=fileparts(binaryNode.Location{1});
                    tlcNode=handler.Resolver.findFile(node,fullfile(pp,'tlc_c',[ff,'.tlc']),{});
                end
                if tlcNode.Resolved
                    deps(end+1)=Dependency.createSource(...
                    component,tlcNode,...
                    this.SFunctionType);%#ok<AGROW>
                end
            end


            for m=1:length(msfunctions)
                sfunction=msfunctions{m};
                if~isempty(sfunction)
                    componentPath=msfunctionPaths{m};
                    component=Component.createBlock(node,componentPath,handler.getSID(componentPath));


                    msfunNode=dependencies.internal.analysis.findSymbol(sfunction);
                    factory=dependencies.internal.analysis.DependencyFactory(...
                    handler,component,this.MSFunctionType.ID);
                    deps=[deps,factory.create(msfunNode)];%#ok<AGROW>


                    tlcNode=handler.Resolver.findFile(node,sfunction,".tlc");
                    if tlcNode.Resolved
                        deps(end+1)=Dependency.createSource(...
                        component,tlcNode,...
                        this.MSFunctionType);%#ok<AGROW>
                    end
                end
            end
        end

    end
end


function binaryNode=i_getBinaryNode(handler,node,sfunction)

    node=handler.Resolver.findFile(node,sfunction,[mexext,".p",".m"]);
    [~,name,ext]=fileparts(node.Location{1});


    if(strcmpi(ext,'.c')||strcmpi(ext,'.cpp'))
        binaryNode=dependencies.internal.graph.Node.createFileNode(name);
    else
        binaryNode=node;
    end
end
