classdef BatchJobReportContent<matlab.internal.project.util.ReportGenerator.ReportContentSpecification

    methods(Access=public)
        function obj=BatchJobReportContent(title,files)
            obj=obj@matlab.internal.project.util.ReportGenerator.ReportContentSpecification(title,files);
        end
    end

    methods(Access=public)
        function reportObject=createSummaryFileDescription(~,file,jObjResult)
            result=jObjResult.getResult(file);
            returnedOutput=char(result.getReturnedOutput());
            strParts=strsplit(returnedOutput,{'\n'});
            reportObject=strParts{1};
        end


        function reportObject=createFileResultsDocumentPart(~,customization,...
            linktarget,...
            headingText,...
            jObjResult,...
            file,...
            homeBookmark)
            result=jObjResult.getResult(file);
            returnedOutput=char(result.getReturnedOutput());

            import Simulink.ModelManagement.Project.BatchJob.Report.FileResultsDocumentPart;
            reportObject=FileResultsDocumentPart(...
            customization,...
            linktarget,...
            headingText,...
            returnedOutput,...
            homeBookmark).create();
        end
    end
end