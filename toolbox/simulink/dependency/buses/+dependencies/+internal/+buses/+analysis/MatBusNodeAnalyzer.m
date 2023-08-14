classdef MatBusNodeAnalyzer<dependencies.internal.analysis.FileAnalyzer




    properties(Constant)
        Extensions=".mat";
        BaseType="MATFile";
    end

    methods
        function deps=analyze(this,handler,fileNode)
            file=fileNode.Location{1};

            import dependencies.internal.buses.util.analyzeMatFile;
            deps=analyzeMatFile(file,handler.Analyzers.Bus.BusNode,fileNode,this.BaseType);
        end
    end

end
