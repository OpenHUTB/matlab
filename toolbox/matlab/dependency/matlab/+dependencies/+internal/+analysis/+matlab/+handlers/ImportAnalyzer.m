classdef ImportAnalyzer<dependencies.internal.analysis.matlab.FunctionAnalyzer




    properties(SetAccess=immutable)
        Functions="import";
        MinimumArguments=1;
        StringArguments=1;
        AllowedArguments=[];
    end

    methods

        function refs=analyze(~,analyzer,ref,depFactory)
            refs=dependencies.internal.analysis.matlab.Reference.empty;
            for n=1:length(ref.InputArguments)
                refs=[refs,i_analyze(analyzer,ref.Workspace,ref.InputArguments(n),depFactory.Node)];%#ok<AGROW>
            end
        end

    end

end


function refs=i_analyze(analyzer,workspace,arg,context)
    import dependencies.internal.analysis.matlab.Reference;

    value=arg.Value;

    if length(value)>1&&strcmp(value(end-1:end),'.*')

        workspace.addRawWildcardImports({value});

        refs=Reference.empty;
        name=value(1:end-2);


        package=meta.package.fromName(name);
        if~isempty(package)
            workspace.addWildcardImports({package.ClassList.Name,package.PackageList.Name});
            i_addNames(workspace,package.Name,{package.FunctionList.Name});
            return;
        end


        class=meta.class.fromName(name);
        if~isempty(class)
            node=analyzer.resolve(context,name);
            refs=Reference(workspace,node,arg.Line,arg.Position,'FunctionArgument');
            i_addNames(workspace,class.Name,{class.MethodList([class.MethodList.Static]).Name});
        end

    else

        node=analyzer.resolve(context,value);
        refs=Reference(workspace,node,arg.Line,arg.Position,'FunctionArgument');
        workspace.addExplicitImports({value});
    end

end


function i_addNames(workspace,root,names)
    for m=1:length(names)
        workspace.addWildcardImports({[root,'.',names{m}]});
    end
end