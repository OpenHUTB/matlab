classdef StateflowEnumeratedConstantAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        EnumeratedConstantType='StateflowEnumeratedConstant';
        EnumTypeIdentifier='Enum:';
    end

    methods

        function this=StateflowEnumeratedConstantAnalyzer()
            import dependencies.internal.analysis.simulink.queries.StateflowQuery
            queries.data=StateflowQuery.createDataQuery("dataType");
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            [enumClasses,enumPaths]=i_findEnums([matches.data.Value],[matches.data.Path]);
            deps=i_createDeps(handler,node,enumClasses,enumPaths,this.EnumeratedConstantType);
        end

    end

end



function[enumClasses,enumPaths]=i_findEnums(dataClasses,dataPaths)

    import dependencies.internal.analysis.simulink.StateflowEnumeratedConstantAnalyzer;

    logicEnumData=startsWith(dataClasses,StateflowEnumeratedConstantAnalyzer.EnumTypeIdentifier);
    enumClasses=extractAfter(dataClasses(logicEnumData),StateflowEnumeratedConstantAnalyzer.EnumTypeIdentifier);
    enumPaths=dataPaths(logicEnumData);
end

function deps=i_createDeps(handler,node,labels,paths,type)
    import dependencies.internal.analysis.matlab.Scope;

    deps=dependencies.internal.graph.Dependency.empty;

    for i=1:length(labels)
        label=strtrim(labels{i});
        target=handler.Resolver.findSymbol(node,label);
        if target.Resolved||~handler.ModelWorkspace.isVariable(label,Scope.File)
            deps(end+1)=dependencies.internal.graph.Dependency(...
            node,paths{i},target,'',type);%#ok<AGROW>
        end
    end


end
