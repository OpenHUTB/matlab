classdef MatlabBusNodeAnalyzer<dependencies.internal.analysis.FileAnalyzer




    properties(Constant)
        Extensions=[".m",".mlx"];
        Type=dependencies.internal.graph.Type("MATLABFile");
    end

    methods
        function deps=analyze(this,handler,fileNode)
            import dependencies.internal.buses.util.CodeUtils
            import dependencies.internal.graph.Component
            file=fileNode.Location{1};
            field=handler.Analyzers.Bus.BusNode.Location{end};
            [~,line]=CodeUtils.search(file,field);

            deps=dependencies.internal.graph.Dependency.empty;
            for n=1:length(line)
                deps(end+1)=createBusDependency(...
                Component.createLine(fileNode,line(n)),...
                handler.Analyzers.Bus.BusNode,this.Type);%#ok<AGROW>
            end
        end
    end

end
