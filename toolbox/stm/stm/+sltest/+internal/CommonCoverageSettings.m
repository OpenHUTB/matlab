classdef CommonCoverageSettings<handle
    properties(Dependent,Abstract)
RecordCoverage
MdlRefCoverage
MetricSettings
CoverageFilterFilename
    end

    properties(Abstract,Hidden)
CollectingCoverage
    end
end