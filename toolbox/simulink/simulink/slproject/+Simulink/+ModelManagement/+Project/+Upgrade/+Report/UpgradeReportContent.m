classdef UpgradeReportContent<matlab.internal.project.util.ReportGenerator.ReportContentSpecification

    methods(Access=public)
        function obj=UpgradeReportContent(title,files)
            obj=obj@matlab.internal.project.util.ReportGenerator.ReportContentSpecification(title,files);
        end
    end

    methods(Access=public)
        function reportObject=createSummaryFileDescription(~,file,jObjResult)
            import com.mathworks.toolbox.slproject.project.GUI.upgrade.view.widgets.report.UpgradeResultInterpreter;
            reportObject=char(UpgradeResultInterpreter.getTranslatedStatus(file,jObjResult));
        end


        function reportObject=createFileResultsDocumentPart(~,customization,...
            linktarget,...
            headingText,...
            jObjResult,...
            file,...
            homeBookmark)
            import Simulink.ModelManagement.Project.Upgrade.Report.FileResultsDocumentPart;
            reportObject=FileResultsDocumentPart(...
            customization,...
            linktarget,...
            headingText,...
            jObjResult,...
            file,...
            homeBookmark).create();
        end
    end
end