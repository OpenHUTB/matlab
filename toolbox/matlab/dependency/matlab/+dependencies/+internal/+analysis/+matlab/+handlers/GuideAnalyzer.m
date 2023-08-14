classdef GuideAnalyzer<dependencies.internal.analysis.matlab.FunctionAnalyzer




    properties(SetAccess=immutable)
        Functions="gui_mainfcn";
        MinimumArguments=0;
        StringArguments=[];
        AllowedArguments=[];
    end

    properties(Access=private)
        File;
    end

    methods

        function this=GuideAnalyzer(file)
            this.File=file;
        end

        function refs=analyze(this,matlabAnalyzer,ref,dependencyFactory)
            import dependencies.internal.analysis.matlab.Reference;

            [~,name]=fileparts(this.File);
            figNode=matlabAnalyzer.findFile(dependencyFactory.Node,name,".fig");
            if figNode.Resolved
                refs=Reference(ref.Workspace,figNode,ref.Function.Line,ref.Function.Position,"GUIDE");
            else
                refs=Reference.empty;
            end
        end

    end

end
