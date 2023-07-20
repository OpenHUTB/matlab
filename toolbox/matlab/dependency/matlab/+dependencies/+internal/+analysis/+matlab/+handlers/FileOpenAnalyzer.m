classdef FileOpenAnalyzer<dependencies.internal.analysis.matlab.FunctionAnalyzer




    properties(SetAccess=immutable)
        FunctionMap;
        Functions;
        MinimumArguments=1;
        StringArguments=1;
        AllowedArguments=[];
    end

    methods

        function this=FileOpenAnalyzer
            this.FunctionMap=i_getFunctionMap;
            this.Functions=this.FunctionMap.keys;
        end

        function refs=analyze(this,matlabAnalyzer,ref,dependencyFactory)
            import dependencies.internal.analysis.matlab.Reference;

            arg=ref.InputArguments(1);

            extensions=this.FunctionMap(ref.Function.Value);
            [~,~,ext]=fileparts(arg.Value);
            if strlength(ext)>0
                extensions(end+1)=ext;
            end

            node=matlabAnalyzer.findFile(dependencyFactory.Node,arg.Value,extensions);
            refs=Reference(ref.Workspace,node,arg.Line,arg.Position,'FunctionArgument');
        end

    end

end


function map=i_getFunctionMap
    map=containers.Map;

    map("getFISCodeGenerationData")=".fis";
    map("readfis")=".fis";
end
