function para=genHyperLinkToToC(reportObj,indent)












    p=inputParser;
    addRequired(p,'reportObj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{}));
    addRequired(p,'indent',...
    @(x)validateattributes(x,{'char'},{'nonempty'}));
    p.parse(reportObj,indent);

    import mlreportgen.dom.*;

    inlnkObj=InternalLink(reportObj.tocLinkTargetName,getString(message('stm:ReportContent:Label_BackToReportSummary')));
    tmpTxt=inlnkObj.Children(1);
    sltest.testmanager.ReportUtility.setTextStyle(tmpTxt,reportObj.BodyFontName,reportObj.BodyFontSize,'blue',false,false);
    para=Paragraph(inlnkObj);
    para.OuterLeftMargin=indent;
end