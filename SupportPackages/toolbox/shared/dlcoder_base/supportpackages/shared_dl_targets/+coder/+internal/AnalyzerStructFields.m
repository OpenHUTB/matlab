classdef AnalyzerStructFields<double

    enumeration
        TargetLibrary(1)
        Supported(2)
        NetworkDiagnostics(3)
        LayerDiagnostics(4)
        IncompatibleLayerTypes(5)
    end

    methods

        function name=fieldName(obj)
            fields=coder.internal.AnalyzeNetworkStructBuilder.FieldNames;
            name=fields{obj};
        end

    end
end