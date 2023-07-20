classdef FileResultsDocumentPart<matlab.internal.project.util.ReportGenerator.ReportObjects.ReportObjectFactory




    properties(Access=private)
ContentsTableLinkTarget
HeadingText
ResultText
HomeBookmark
    end

    methods(Access=public)
        function obj=FileResultsDocumentPart(customisation,linkTarget,headingText,resultText,homeBookmark)
            obj=obj@matlab.internal.project.util.ReportGenerator.ReportObjects.ReportObjectFactory(customisation);
            obj.ContentsTableLinkTarget=linkTarget;
            obj.HeadingText=headingText;
            obj.ResultText=resultText;
            obj.HomeBookmark=homeBookmark;
        end

        function documentPart=create(obj)
            import mlreportgen.dom.DocumentPart;
            documentPart=DocumentPart(obj.Customisation.FileType);

            import mlreportgen.dom.Heading;
            import mlreportgen.dom.PageBreakBefore;
            headingObject=Heading(2,obj.ContentsTableLinkTarget);
            headingObject.Style={PageBreakBefore(true)};
            headingObject.append(obj.HeadingText);
            documentPart.append(headingObject);

            resultsHeadingObject=Heading(4,getString(message('SimulinkProject:BatchJob:result')));
            documentPart.append(resultsHeadingObject);

            import mlreportgen.dom.HTML;
            import mlreportgen.dom.WhiteSpace;
            try
                formattedOutput=HTML(obj.ResultText);
                formattedOutput.Style={WhiteSpace('preserve')};
            catch exception %#ok<NASGU>
                formattedOutput=obj.ResultText;
            end

            documentPart.append(formattedOutput);

            import mlreportgen.dom.InternalLink;
            documentPart.append(InternalLink(obj.HomeBookmark,getString(message('SimulinkProject:util:endOfSection'))));
        end
    end

end

