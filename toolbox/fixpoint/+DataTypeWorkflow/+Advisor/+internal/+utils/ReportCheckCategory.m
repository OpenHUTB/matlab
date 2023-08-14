classdef ReportCheckCategory







    enumeration
HardwareSetting
DiagnosticSetting
UnsupportedConstruct
DesignRange
SUDBoundary
RestorePoint
Unknown
    end

    methods(Static)
        function enumValue=convertCheckCategoryToEnum(checkCategory)
            enumValueFunctionHandle=@(x)DataTypeWorkflow.Advisor.internal.utils.ReportCheckCategory(x);
            switch checkCategory
            case "HardwareSetting"
                enumValue=enumValueFunctionHandle("HardwareSetting");
            case "DiagnosticSetting"
                enumValue=enumValueFunctionHandle("DiagnosticSetting");
            case "UnsupportedConstruct"
                enumValue=enumValueFunctionHandle("UnsupportedConstruct");
            case "DesignRange"
                enumValue=enumValueFunctionHandle("DesignRange");
            case "SUDBoundary"
                enumValue=enumValueFunctionHandle("SUDBoundary");
            case "RestorePoint"
                enumValue=enumValueFunctionHandle("RestorePoint");
            otherwise
                enumValue=enumValueFunctionHandle("Unknown");
            end
        end
    end
end


