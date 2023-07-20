classdef Summary<coder.report.ReportPageBase





    properties


AuthorName
LastModifiedBy

Hardware
HardwareDeviceType

ModelName
ModelVersion

TargetLang


SysTargetFile

CoderAssumptionCheckResult

TaskingMode

TimeStamp
CoderVersion


CodeGenFolder
BInfoMat
SubsystemPathAndName

ExportedString
BuildType


InstructionSetExtensions
IsFmaTriggered


isReductionTriggered
    end



    methods
        function obj=Summary(model)
            obj=obj@coder.report.ReportPageBase();
            obj.ModelName=model;


            obj.AuthorName=get_param(model,'Creator');
            obj.LastModifiedBy=get_param(model,'LastModifiedBy');


            obj.ModelVersion=get_param(model,'ModelVersion');
            obj.TargetLang=strtok(get_param(model,'TargetLang'));

            obj.TaskingMode=get_param(model,'EnableMultiTasking');


            obj.SysTargetFile=get_param(model,'SystemTargetFile');
            obj.HardwareDeviceType=get_param(model,'ProdHWDeviceType');





            if((strcmp(get_param(model,'isexportfunctionmodel'),'on'))||(contains(get_param(model,'TLCOptions'),'-aExportFunctionsMode=1')))
                obj.ExportedString=[message('RTW:report:SummaryExportedString').getString,' '];
            else
                obj.ExportedString='';
            end


            obj.InstructionSetExtensions=get_param(model,'InstructionSetExtensions');
            obj.IsFmaTriggered=false;

        end
    end

    methods(Access=public)

        updateSummary(obj,modelName);
    end

    methods(Access=private)
        out=getSummary(obj)
        out=getModelSummary(obj);
        out=getCodeSummary(obj);
        out=getConfigSummary(obj);
        loadCodeMetricsFiles(obj);
        updateSimdFmaUsage(obj,modelName);
    end

    methods(Hidden=true)
        setBuildType(obj,MdlRefBuildArgs);
    end

    methods(Static=true)
        aTable=genConfigCheckReportTable(currentModelName,varargin)
    end
end





