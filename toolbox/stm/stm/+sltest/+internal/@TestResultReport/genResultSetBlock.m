function groupObj=genResultSetBlock(reportObj,result)













    p=inputParser;
    addRequired(p,'reportObj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{}));
    addRequired(p,'result',...
    @(x)validateattributes(x,{'sltest.testmanager.ReportUtility.ReportResultData'},{}));
    p.parse(reportObj,result);

    import mlreportgen.dom.*;

    groupObj=Group();
    resultObj=result.Data;
    text=Text(resultObj.Name);
    sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.HeadingFontName,...
    reportObj.HeadingFontSize,reportObj.HeadingFontColor,true,false);
    append(groupObj,Paragraph(text));

    table=FormalTable(2);
    table.OuterLeftMargin=reportObj.ChapterIndent;
    groups=sltest.testmanager.ReportUtility.genTableColSpecGroup([{'4cm'},{'10cm'}]);
    table.ColSpecGroups=groups;
    table.TableEntriesStyle={OuterMargin('0mm')};
    table.Style=[table.Style,{ResizeToFitContents(false)}];

    rowList=reportObj.genTableRowsForResultMetaInfo(result);
    for k=1:length(rowList)
        append(table,rowList(k));
    end


    lnkTargetName=sprintf('%s',result.UID);
    table.Body.entry(1,1).Children(1).append(LinkTarget(lnkTargetName));
    append(groupObj,table);


    if(reportObj.IncludeCoverageResult==true&&isempty(result.ParentResultName))
        table=reportObj.genCoverageTable(result.Data);
        append(groupObj,table);
    end

    linkPara=reportObj.genHyperLinkToToC(reportObj.ChapterIndent);
    append(groupObj,linkPara);
end