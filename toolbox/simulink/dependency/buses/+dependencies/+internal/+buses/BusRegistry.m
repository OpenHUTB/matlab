classdef(Sealed,SupportExtensionMethods=true)BusRegistry<dependencies.internal.engine.DependencyRegistry




    properties(Constant)
        Instance=dependencies.internal.buses.BusRegistry;
    end

    properties(GetAccess=public,SetAccess=private)
SharedAnalyzerFactories
NodeAnalyzers
FunctionAnalyzers
ModelAnalyzers
NodeHandlers
DependencyHandlers
RefactoringHandlers
GraphReaders
GraphWriters
ViewCustomizations
AnalysisCustomizations
    end

    methods(Access=private)
        function this=BusRegistry
        end
    end

    methods
        function analyzers=get.NodeAnalyzers(this)
            if isempty(this.NodeAnalyzers)
                this.NodeAnalyzers=[
                dependencies.internal.buses.analysis.BaseWorkspaceNodeAnalyzer
                dependencies.internal.buses.analysis.DataDictionaryNodeAnalyzer
                dependencies.internal.buses.analysis.MatlabBusNodeAnalyzer
                dependencies.internal.buses.analysis.MatBusNodeAnalyzer
                dependencies.internal.analysis.simulink.SimulinkNodeAnalyzer(this.ModelAnalyzers)
                dependencies.internal.analysis.simulink.TestHarnessNodeAnalyzer(this.ModelAnalyzers)
                ];
            end
            analyzers=this.NodeAnalyzers;
        end

        function analyzers=get.ModelAnalyzers(this)
            if isempty(this.ModelAnalyzers)
                this.ModelAnalyzers=[
                dependencies.internal.buses.analysis.BusPortAnalyzer
                dependencies.internal.buses.analysis.CallbackAnalyzer
                dependencies.internal.buses.analysis.CodeInParamAnalyzer
                dependencies.internal.buses.analysis.InitialValueAnalyzer
                dependencies.internal.buses.analysis.ModelWorkspaceAnalyzer
                dependencies.internal.buses.analysis.OutDataTypeAnalyzer
                dependencies.internal.buses.analysis.SignalNameAnalyzer
                dependencies.internal.buses.analysis.StateflowDataAnalyzer
                dependencies.internal.buses.analysis.StateflowMATLABFunctionsAnalyzer
                dependencies.internal.buses.analysis.StateflowStatesAndTransitionsAnalyzer
                dependencies.internal.buses.analysis.SymbolSeparatedParamAnalyzer
                dependencies.internal.analysis.simulink.TestHarnessAnalyzer
                ];
            end
            analyzers=this.ModelAnalyzers;
        end

        function handlers=get.RefactoringHandlers(this)
            if isempty(this.RefactoringHandlers)
                this.RefactoringHandlers=[
                dependencies.internal.buses.refactoring.BusPortHandler
                dependencies.internal.buses.refactoring.CallbackHandler
                dependencies.internal.buses.refactoring.FunctionParamsHandler
                dependencies.internal.buses.refactoring.MatlabFileBusHandler
                dependencies.internal.buses.refactoring.MatlabFunctionHandler
                dependencies.internal.buses.refactoring.OutDataTypeHandler
                dependencies.internal.buses.refactoring.SignalNameHandler
                dependencies.internal.buses.refactoring.SymbolSeparatedParamsHandler
                dependencies.internal.buses.refactoring.VariableRefactoringHandler
                ];

                if dependencies.internal.util.isProductInstalled("SF")
                    this.RefactoringHandlers(end+1)=dependencies.internal.buses.refactoring.StateflowDataHandler;
                    this.RefactoringHandlers(end+1)=dependencies.internal.buses.refactoring.StateflowLabelHandler;
                end
            end

            handlers=this.RefactoringHandlers;
        end
    end

end
