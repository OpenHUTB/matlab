classdef Subsystem<coder.report.ReportPageBase





    properties(Access=private)
ModelName
ReuseDiag
TargetLang
    end

    methods
        function obj=Subsystem(modelName,sourceSubsystem)
            obj=obj@coder.report.ReportPageBase;
            obj.ModelName=modelName;
            obj.TargetLang=get_param(modelName,'TargetLang');
            obj.setCodeReuseDiagnostics(sourceSubsystem);
        end
    end

    methods(Access=private)
        setCodeReuseDiagnostics(obj,sourceSubsystem)
        addCodeMappingSection(obj)
        addCodeReuseExceptionSection(obj)
        addLibraryCodeReuseExceptionSection(obj)
        retVal=getDiagInfo(obj,isNewAPI)
        retVal=getReuseExceptions(obj)
        appendRptgenReuseExceptions(obj,chapter)
    end
end


