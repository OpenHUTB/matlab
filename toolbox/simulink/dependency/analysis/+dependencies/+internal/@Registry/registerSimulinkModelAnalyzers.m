function analyzers=registerSimulinkModelAnalyzers(~)




    import dependencies.internal.analysis.simulink.*;

    analyzers=dependencies.internal.analysis.simulink.ModelAnalyzer.empty;

    if dependencies.internal.util.isProductInstalled('SL','simulink')
        analyzers=[
DataDictionaryAnalyzer
ModelWorkspaceAnalyzer
MaskedBlockAnalyzer
ModelReferenceAnalyzer
SubsystemReferenceAnalyzer
LibraryLinksAnalyzer
LibraryForwardingTableAnalyzer
RequirementsAnalyzer
ModelCallbackAnalyzer
BlockCallbackAnalyzer
FromFileBlockAnalyzer
PlaybackBlockAnalyzer
FromSpreadsheetBlockAnalyzer
SignalEditorBlockAnalyzer
EnumeratedConstantAnalyzer
StateflowEnumeratedConstantAnalyzer
InterpretedMatlabFunctionBlockAnalyzer
SystemObjectsAnalyzer
SFunctionAnalyzer
SFunctionBuilderAnalyzer
ToolboxBlocksAnalyzer
ModelDependenciesParameterAnalyzer
PackagedModelAnalyzer
LoggingAnalyzer
CodeGenAnalyzer
SimulinkDesignVerifierAnalyzer
StateflowWorkspaceAnalyzer
StateflowAnalyzer
EMLAnalyzer
SimMechanicsAnalyzer
TestHarnessAnalyzer
CoreBlockToolboxAnalyzer
FMUAnalyzer
ObserverReferenceAnalyzer
NotesAnalyzer
CommentsAnalyzer
        ];
    end

    if dependencies.internal.util.isProductInstalled('SS','simscape')
        analyzers(end+1)=SimscapeAnalyzer;
    end

end
