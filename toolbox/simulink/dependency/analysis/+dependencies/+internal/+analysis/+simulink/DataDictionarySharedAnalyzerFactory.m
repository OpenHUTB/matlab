classdef DataDictionarySharedAnalyzerFactory<dependencies.internal.analysis.SharedAnalyzerFactory




    properties(Constant)
        Name="SLDD";
    end

    properties(GetAccess=private,SetAccess=immutable)
        Dictionaries;
    end

    methods
        function this=DataDictionarySharedAnalyzerFactory()
        end

        function sharedAnalyzer=create(~)
            sharedAnalyzer=dependencies.internal.analysis.simulink.DataDictionarySharedAnalyzer();
        end
    end
end
