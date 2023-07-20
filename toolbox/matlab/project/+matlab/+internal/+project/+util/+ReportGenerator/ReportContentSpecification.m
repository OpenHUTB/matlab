classdef(Abstract)ReportContentSpecification






    properties(Access=protected)
Title
Files
    end

    methods(Access=public)
        function obj=ReportContentSpecification(title,files)
            obj.Title=title;
            obj.Files=files;
        end

        function files=getFiles(obj)
            files=obj.Files;
        end

        function title=getTitle(obj)
            title=obj.Title;
        end
    end

    methods(Access=public,Abstract=true)
        reportObject=createSummaryFileDescription(obj,...
        file,...
        jObjResult);

        reportObject=createFileResultsDocumentPart(obj,...
        customization,...
        linktarget,...
        headingText,...
        jObjResult,...
        file,...
        homeBookmark);
    end
end

