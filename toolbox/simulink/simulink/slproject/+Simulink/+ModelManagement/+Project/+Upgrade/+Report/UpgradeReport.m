classdef UpgradeReport




    methods(Access=public,Static=true)
        function bjr=generateReport(projectName,projectLocation,repositoryLocation,results,docTypeString,filePath)
            import matlab.internal.project.util.ReportGenerator.Report;
            import Simulink.ModelManagement.Project.Upgrade.Report.UpgradeReportContent;
            title=getString(message('SimulinkProject:Upgrade:title'));
            files=results.getFiles();
            upgradeContentSpecification=UpgradeReportContent(title,files);
            bjr=matlab.internal.project.util.ReportGenerator.Report.generateReport(...
            projectName,projectLocation,repositoryLocation,results,docTypeString,filePath,upgradeContentSpecification);
        end

        function generateReportAndShow(projectName,projectLocation,repositoryLocation,results,docTypeString,filePath)
            import matlab.internal.project.util.ReportGenerator.Report;
            import Simulink.ModelManagement.Project.Upgrade.Report.UpgradeReport;
            bjr=UpgradeReport.generateReport(projectName,projectLocation,repositoryLocation,results,docTypeString,filePath);
            bjr.displayReport();
        end
    end
end