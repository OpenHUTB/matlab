function analyzers=registerDefaultFunctionAnalyzers(~)





    import dependencies.internal.analysis.matlab.handlers.*;

    analyzers=[
FileOpenAnalyzer
WhichAnalyzer
EvalAnalyzer
EvalinAnalyzer
AssigninAnalyzer
LoadAnalyzer
ImportAnalyzer
ImportDataAnalyzer
    ];

end

