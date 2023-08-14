classdef BatchJobReport




    methods(Access=public,Static=true)
        function bjr=generateReport(projectName,projectLocation,repositoryLocation,results,docTypeString,filePath)
            import matlab.internal.project.util.ReportGenerator.Report;
            import Simulink.ModelManagement.Project.BatchJob.Report.BatchJobReportContent;

            if strcmp(docTypeString,'pdf')



                if~builtin('license','checkout','matlab_report_gen')
                    errordlg(...
                    getString(message('SimulinkProject:BatchJob:NoMLRptGenLicense')),...
                    getString(message('SimulinkProject:BatchJob:NoMLRptGenLicenseTitle'))...
                    );
                    bjr=[];
                    return
                end
            end
            title=char(results.getDefinition().getCommand());
            files=results.getDefinition().getFiles();
            batchJobContentSpecification=BatchJobReportContent(title,files);
            bjr=matlab.internal.project.util.ReportGenerator.Report.generateReport(...
            projectName,projectLocation,repositoryLocation,results,docTypeString,filePath,batchJobContentSpecification);
        end

        function generateReportAndShow(projectName,projectLocation,repositoryLocation,results,docTypeString,filePath)
            import matlab.internal.project.util.ReportGenerator.Report;
            import Simulink.ModelManagement.Project.BatchJob.Report.BatchJobReport;

            bjr=BatchJobReport.generateReport(projectName,projectLocation,repositoryLocation,results,docTypeString,filePath);
            if~isempty(bjr)
                bjr.displayReport();
            end
        end
    end
end