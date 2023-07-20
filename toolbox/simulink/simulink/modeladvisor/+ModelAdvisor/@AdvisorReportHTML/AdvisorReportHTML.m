classdef(CaseInsensitiveProperties=true)AdvisorReportHTML<ModelAdvisor.AdvisorReportBase




    methods(Access=public)



        function obj=AdvisorReportHTML()
            obj.ReportPath='';
        end


        function result=generateReportForNode(this,TaskNode)
            result='';
            if this.validateReportPath
                srcFilename=['report_',num2str(TaskNode.index),'.html'];
                result=this.exportReport(srcFilename);
            end
        end

        function result=generateReportForChecks(this,CheckList)
            result='';
            if this.validateReportPath
                srcFilename='report.html';
                result=this.exportReport(srcFilename);
            end
        end

    end

    methods(Access=private)




        function result=exportReport(this,srcFilename)
            result='';
            MdlAdvHandle=Simulink.ModelAdvisor.getModelAdvisor(this.ModelName);
            dstFileName=[this.ReportPath,filesep,this.ReportName,'.html'];
            [success,]=MdlAdvHandle.exportReport(dstFileName,srcFilename);
            if(success)
                result=dstFileName;
                srcFile=fullfile(MdlAdvHandle.getWorkDir('CheckOnly'),srcFilename);
                delete(srcFile)
            end
        end

    end

end


