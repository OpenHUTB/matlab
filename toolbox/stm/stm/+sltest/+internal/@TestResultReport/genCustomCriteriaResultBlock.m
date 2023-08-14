function docPart=genCustomCriteriaResultBlock(reportObj,testResult)















    p=inputParser;
    addRequired(p,'obj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{}));
    addRequired(p,'result',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResult'},{}));
    p.parse(reportObj,testResult);

    import mlreportgen.dom.*;
    customCriteriaResult=testResult.getCustomCriteriaResult;
    if isempty(customCriteriaResult)

        docPart=Group.empty;
    else

        docPart=Group();


        addHeader(docPart,reportObj);


        addDiagnosticRecords(docPart,reportObj,customCriteriaResult);


        append(docPart,sltest.testmanager.ReportUtility.vspace(reportObj.SectionSpacing));
    end
end

function addHeader(docPart,reportObj)
    import mlreportgen.dom.*;
    text=Text(getString(message('stm:ReportContent:CustomCriteriaResultHeader')));
    sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.BodyFontName,...
    reportObj.BodyFontSize,reportObj.BodyFontColor,true,false);
    para=Paragraph();
    append(para,text);
    para.OuterLeftMargin=reportObj.ChapterIndent;
    append(docPart,para);
end

function addDiagnosticRecords(docPart,reportObj,customCriteriaResult)
    for i=1:length(customCriteriaResult.DiagnosticRecord)
        drPart=genDiagnosticRecordBlock(reportObj,customCriteriaResult.DiagnosticRecord(i));
        append(docPart,drPart);
        append(docPart,sltest.testmanager.ReportUtility.vspace(reportObj.SectionSpacing));
    end
end
