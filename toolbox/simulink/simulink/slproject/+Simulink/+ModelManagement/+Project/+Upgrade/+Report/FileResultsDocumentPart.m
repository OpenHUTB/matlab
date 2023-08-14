classdef FileResultsDocumentPart<matlab.internal.project.util.ReportGenerator.ReportObjects.ReportObjectFactory




    properties(Access=private)
ContentsTableLinkTarget
HeadingText
UpgradeResult
File
HomeBookmark
    end

    methods(Access=public)
        function obj=FileResultsDocumentPart(customisation,linkTarget,headingText,upgradeResult,file,homeBookmark)
            obj=obj@matlab.internal.project.util.ReportGenerator.ReportObjects.ReportObjectFactory(customisation);
            obj.ContentsTableLinkTarget=linkTarget;
            obj.HeadingText=headingText;
            obj.UpgradeResult=upgradeResult;
            obj.File=file;
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

            import com.mathworks.toolbox.slproject.project.GUI.upgrade.view.widgets.report.UpgradeResultInterpreter;
            cancelled=UpgradeResultInterpreter.isCancelled(obj.File,obj.UpgradeResult);
            checks=UpgradeResultInterpreter.getChecksToReport(obj.File,obj.UpgradeResult);

            if cancelled
                documentPart.append(mlreportgen.dom.Paragraph(getString(message('SimulinkProject:Upgrade:Canceled'))));
            elseif checks.isEmpty
                documentPart.append(mlreportgen.dom.Paragraph(getString(message('SimulinkProject:Upgrade:AllChecksPassed'))));
            else
                checksArray=checks.toArray;
                for n=1:checks.size
                    documentPart.append(obj.createPartForCheck(checksArray(n)));
                end
            end

            import mlreportgen.dom.InternalLink;
            documentPart.append(InternalLink(obj.HomeBookmark,getString(message('SimulinkProject:util:endOfSection'))));
        end
    end

    methods(Access=private)
        function documentPart=createPartForCheck(obj,check)
            documentPart=mlreportgen.dom.DocumentPart(obj.Customisation.FileType);

            heading=mlreportgen.dom.Heading(4);
            heading.append(char(check.getTitle()));
            documentPart.append(heading);

            preResult=obj.UpgradeResult.getResult(obj.File,check);
            fixResult=obj.UpgradeResult.getFixResult(obj.File,check);
            finalResult=obj.UpgradeResult.getFinalResult(obj.File,check);

            hasPreResult=~isempty(preResult);
            hasFixResult=~isempty(fixResult);
            hasFinalResult=~isempty(finalResult);

            if hasPreResult
                if hasFixResult||hasFinalResult
                    documentPart.append(i_getTitle('project.upgrade.report.preCheck'));
                end
                documentPart.append(i_getText(preResult));
            end

            if hasFixResult
                documentPart.append(i_getTitle('project.upgrade.report.autoFix'));
                documentPart.append(i_getText(fixResult));
            end

            if hasFinalResult
                documentPart.append(i_getTitle('project.upgrade.report.postCheck'));
                documentPart.append(i_getText(finalResult));
            end
        end
    end

end


function text=i_getTitle(id)
    title=char(com.mathworks.toolbox.slproject.resources.SlProjectResources.getUpgradeString(id,[]));
    try
        text=mlreportgen.dom.HTML(title);
        text.Style={mlreportgen.dom.WhiteSpace('preserve')};
    catch
        text=title;
    end
end


function text=i_getText(result)
    text=mlreportgen.dom.RawText(char(result.getResultText));
end

