classdef(CaseInsensitiveProperties=true)AdvisorReportBase<matlab.mixin.Copyable




    properties(Access=public)
        ModelName='';
        ReportName='report';
        ReportPath='';
    end

    properties(Access=protected)
        TaskNode=[];
        CheckList=[];
        ShowReportOnGeneration=false;
    end

    methods(Abstract)
        result=generateReportForNode(TaskNode)
        result=generateReportForChecks(CheckList)
    end

    methods
        function set.ReportName(obj,filename)
            if isempty(filename)
                obj.ReportName='report';
            else
                [fid,msg]=fopen(filename,'w');
                if(fid<0)
                    DAStudio.warning('ModelAdvisor:engine:CmdAPIReportNameParamInValid');
                    obj.ReportName='report';
                else
                    obj.ReportName=filename;
                    fclose(fid);
                    delete(filename);
                end
            end
        end
    end

    methods(Access=protected)
        function result=validateReportPath(obj)
            result=true;

            if isempty(obj.ReportPath)
                mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
                obj.ReportPath=mdladvObj.getWorkDir;
            end
            if~exist(obj.ReportPath,"dir")
                result=false;
                DAStudio.warning('ModelAdvisor:engine:CmdAPIReportPathParamInValid');
            end
        end
    end

end


