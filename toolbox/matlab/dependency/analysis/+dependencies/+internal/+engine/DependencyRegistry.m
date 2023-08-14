classdef(Abstract)DependencyRegistry<handle




    properties(Abstract,GetAccess=public,SetAccess=private)
        SharedAnalyzerFactories(:,1)dependencies.internal.analysis.SharedAnalyzerFactory;
        NodeAnalyzers(:,1)dependencies.internal.analysis.NodeAnalyzer;
        FunctionAnalyzers(:,1)dependencies.internal.analysis.matlab.FunctionAnalyzer;
        ModelAnalyzers(:,1)dependencies.internal.analysis.simulink.ModelAnalyzer;
        NodeHandlers(:,1)dependencies.internal.action.NodeHandler;
        DependencyHandlers(:,1)dependencies.internal.action.DependencyHandler;
        RefactoringHandlers(:,1)dependencies.internal.action.RefactoringHandler;
        GraphReaders(:,1)dependencies.internal.graph.GraphReader;
        GraphWriters(:,1)dependencies.internal.graph.GraphWriter;
        ViewCustomizations(:,1)dependencies.internal.viewer.ViewCustomization;
        AnalysisCustomizations(:,1)dependencies.internal.engine.AnalysisCustomization;
    end

    methods
        function extensions=getAnalysisExtensions(this)
            extensions=unique([this.NodeAnalyzers.Extensions]);
        end

        function extensions=getGraphReaderExtensions(this)
            extensions=unique([this.GraphReaders.Extensions]);
        end

        function extensions=getGraphWriterExtensions(this)
            extensions=unique([this.GraphWriters.Extensions]);
        end

        function[renameTypes,folderTypes]=getRefactoringTypes(this)
            handlers=this.RefactoringHandlers;
            renameOnly=[handlers.RenameOnly];

            renameTypes=vertcat(handlers.Types);
            folderTypes=vertcat(handlers(~renameOnly).Types);

            if isempty(renameTypes)
                renameTypes={};
            end
            if isempty(folderTypes)
                folderTypes={};
            end
        end
    end

end
