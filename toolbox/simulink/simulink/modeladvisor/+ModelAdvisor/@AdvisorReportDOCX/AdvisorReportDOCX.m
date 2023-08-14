classdef(CaseInsensitiveProperties=true)AdvisorReportDOCX<ModelAdvisor.AdvisorReportTemplate





    methods(Access=public)

        function obj=AdvisorReportDOCX()
            obj=obj@ModelAdvisor.AdvisorReportTemplate();
        end


        function result=generateReportForNode(obj,TaskNode)
            result='';
            if obj.validateReportPath
                obj.createNodeStructure(TaskNode);
                result=obj.createReport(getFileName(obj),'docx');
            end
        end

        function result=generateReportForChecks(obj,CheckList)
            result='';
            if obj.validateReportPath
                obj.createCheckStructure(CheckList);
                result=obj.createReport(getFileName(obj),'docx');
            end
        end

    end

    methods(Access=protected)
        function fName=getFileName(obj)
            fName=[obj.ReportPath,filesep,obj.ReportName,'.docx'];
        end

        function result=createNodeStructure(obj,TaskNode)
            result=obj.createNodeStructure@ModelAdvisor.AdvisorReportTemplate(TaskNode);
        end

        function result=createCheckStructure(obj,CheckList)
            result=obj.createCheckStructure@ModelAdvisor.AdvisorReportTemplate(CheckList);
        end
    end

end


