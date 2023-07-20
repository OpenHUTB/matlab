classdef(Sealed,SupportExtensionMethods=true)Registry<dependencies.internal.engine.DependencyRegistry&dependencies.internal.GenericRegistry




    properties(Constant)
        Instance=dependencies.internal.Registry;
    end

    properties(GetAccess=public,SetAccess=private)
        SharedAnalyzerFactories=dependencies.internal.analysis.SharedAnalyzerFactory.empty;
        NodeAnalyzers=dependencies.internal.analysis.NodeAnalyzer.empty;
        FunctionAnalyzers=dependencies.internal.analysis.matlab.FunctionAnalyzer.empty;
        ModelAnalyzers=dependencies.internal.analysis.simulink.ModelAnalyzer.empty;
        NodeHandlers=dependencies.internal.action.NodeHandler.empty;
        DependencyHandlers=dependencies.internal.action.DependencyHandler.empty;
        RefactoringHandlers=dependencies.internal.action.RefactoringHandler.empty;
        GraphReaders=dependencies.internal.graph.GraphReader.empty;
        GraphWriters=dependencies.internal.graph.GraphWriter.empty;
        ViewCustomizations=dependencies.internal.viewer.ViewCustomization.empty;
        AnalysisCustomizations=dependencies.internal.engine.AnalysisCustomization.empty;
    end

    methods(Access=private)
        function this=Registry
        end
    end

    methods
        function refresh(this)
            class=metaclass(this);
            names={class.PropertyList.Name};
            applicable=~[class.PropertyList.Constant];

            for n=find(applicable)
                this.(names{n})=class.PropertyList(n).DefaultValue;
            end
        end

        function analyzers=get.SharedAnalyzerFactories(this)
            if isempty(this.SharedAnalyzerFactories)
                this.SharedAnalyzerFactories=this.register('SharedAnalyzerFactories');
            end
            analyzers=this.SharedAnalyzerFactories;
        end

        function analyzers=get.NodeAnalyzers(this)
            if isempty(this.NodeAnalyzers)
                this.NodeAnalyzers=this.register('NodeAnalyzers');
            end
            analyzers=this.NodeAnalyzers;
        end

        function analyzers=get.FunctionAnalyzers(this)
            if isempty(this.FunctionAnalyzers)
                this.FunctionAnalyzers=this.register('FunctionAnalyzers');
            end
            analyzers=this.FunctionAnalyzers;
        end

        function analyzers=get.ModelAnalyzers(this)
            if isempty(this.ModelAnalyzers)
                this.ModelAnalyzers=this.register('ModelAnalyzers');
            end
            analyzers=this.ModelAnalyzers;
        end

        function handlers=get.NodeHandlers(this)
            if isempty(this.NodeHandlers)
                this.NodeHandlers=this.register('NodeHandlers');
            end
            handlers=this.NodeHandlers;
        end

        function handlers=get.DependencyHandlers(this)
            if isempty(this.DependencyHandlers)
                this.DependencyHandlers=this.register('DependencyHandlers');
            end
            handlers=this.DependencyHandlers;
        end

        function handlers=get.RefactoringHandlers(this)
            if isempty(this.RefactoringHandlers)
                this.RefactoringHandlers=this.register('RefactoringHandlers');
            end
            handlers=this.RefactoringHandlers;
        end

        function readers=get.GraphReaders(this)
            if isempty(this.GraphReaders)
                this.GraphReaders=this.register('GraphReaders');
            end
            readers=this.GraphReaders;
        end

        function writers=get.GraphWriters(this)
            if isempty(this.GraphWriters)
                this.GraphWriters=this.register('GraphWriters');
            end
            writers=this.GraphWriters;
        end

        function customizations=get.ViewCustomizations(this)
            if isempty(this.ViewCustomizations)
                this.ViewCustomizations=this.register('ViewCustomizations');
            end
            customizations=this.ViewCustomizations;
        end

        function customizations=get.AnalysisCustomizations(this)
            if isempty(this.AnalysisCustomizations)
                this.AnalysisCustomizations=this.register('AnalysisCustomizations');
            end
            customizations=this.AnalysisCustomizations;
        end
    end

end
