function[analysisTypes,renameTypes,folderTypes]=getRegistryInfo(jCommand)




    registry=eval(char(jCommand));
    analysisTypes=cellstr(registry.getAnalysisExtensions);
    [renameTypes,folderTypes]=registry.getRefactoringTypes;



    analysisTypes=[analysisTypes,cellstr(dependencies.internal.analysis.ccode.CCodeNodeAnalyzer.Extensions)];



    folderTypes=[...
    folderTypes;...
    {'BlockCallback,MaskDisplay,FunctionArgument';...
    'ModelReferenceDependency';...
    'CustomLibrary';...
    'CustomSource';...
    'StateflowTarget'}];

end

