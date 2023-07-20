classdef CodeInterface<coder.report.ReportPageBase






    properties
ModelName
BuildDir
PlatformType
        ReportCodeIdentifier=true
    end

    properties(Transient)
CodeInfo
    end

    methods
        function obj=CodeInterface(modelName,buildDir)
            obj.ModelName=modelName;
            obj.BuildDir=buildDir;
            obj.PlatformType=coder.dictionary.internal.getPlatformType(modelName);
        end
        function out=getRelevantType(~,portData)
            out=portData.Implementation.Type;
        end
        function out=hasEntryPointFcns(~)
            out=true;
        end
    end
end


