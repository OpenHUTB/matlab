classdef(CaseInsensitiveProperties=true)AdvisorReportPDF<ModelAdvisor.AdvisorReportTemplate





    methods(Access=public)

        function obj=AdvisorReportPDF()
            obj=obj@ModelAdvisor.AdvisorReportTemplate();
        end

        function result=generateReportForNode(obj,TaskNode)
            result='';
            if obj.validateReportPath
                obj.createNodeStructure(TaskNode);
                result=obj.createReport(getFileName(obj),'docx');
                result=obj.convertToPDF(result);
            end
        end

        function result=generateReportForChecks(obj,CheckList)
            result='';
            if obj.validateReportPath
                obj.createCheckStructure(CheckList);
                result=obj.createReport(getFileName(obj),'docx');
                result=obj.convertToPDF(result);
            end
        end

    end

    methods(Access=protected)

        function fName=getFileName(obj)
            fName=[tempname,'.docx'];
        end

        function result=createNodeStructure(obj,TaskNode)
            result=obj.createNodeStructure@ModelAdvisor.AdvisorReportTemplate(TaskNode);
        end

        function result=createCheckStructure(obj,CheckList)
            result=obj.createCheckStructure@ModelAdvisor.AdvisorReportTemplate(CheckList);
        end

        function result=convertToPDF(obj,rptname)
            origName=[obj.ReportPath,filesep,obj.ReportName,'.pdf'];
            result=origName;
            rptgen.docview(rptname,'convertdocxtopdf');
            [success,message,~]=copyfile([rptname(1:end-4),'pdf'],origName);
            if~success
                DAStudio.warning(message);
                result='';
            end
            delete(rptname);
        end
    end

end


