classdef EnumeratedConstantAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        EnumeratedConstantType=dependencies.internal.graph.Type("EnumeratedConstant");
    end

    methods

        function this=EnumeratedConstantAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createParameterQuery
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createInstanceDataParameterQuery

            queries.OutDataTypeStr=createParameterQuery('OutDataTypeStr');
            queries.InstanceDataOutDataTypeStr=createInstanceDataParameterQuery('OutDataTypeStr');
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            types=string([matches.OutDataTypeStr.Value,matches.InstanceDataOutDataTypeStr.Value]);
            blocks=[matches.OutDataTypeStr.BlockPath,matches.InstanceDataOutDataTypeStr.BlockPath];

            deps=[...
            this.findEnums(handler,node,types,blocks,'Enum:')...
            ,this.findEnums(handler,node,types,blocks,'?')...
            ];
        end

    end

    methods(Access=private)

        function deps=findEnums(this,handler,node,types,blocks,identifier)
            import dependencies.internal.analysis.matlab.Scope;
            import dependencies.internal.graph.Component;
            deps=dependencies.internal.graph.Dependency.empty;
            for n=find(types.startsWith(identifier))
                name=types(n).extractAfter(length(identifier)).strip;
                if strlength(name)>0
                    target=handler.Resolver.findSymbol(node,name.char);
                    if target.Resolved||~handler.ModelWorkspace.isVariable(name.char,Scope.File)
                        blockComp=Component.createBlock(node,blocks{n},handler.getSID(blocks{n}));
                        deps(end+1)=dependencies.internal.graph.Dependency.createSource(...
                        blockComp,target,this.EnumeratedConstantType);%#ok<AGROW>
                    end
                end
            end
        end
    end

end
