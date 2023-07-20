classdef BuildSummaryEntry




    properties
        Key char
        Model char
        Target char
        RebuildReason char
        WasCodeGenerated(1,1)logical
        WasCodeCompiled(1,1)logical
        WasBuildSuccessful(1,1)logical
        DisplayOrder(1,1)double
        ActionUnknown(1,1)logical
    end
end

