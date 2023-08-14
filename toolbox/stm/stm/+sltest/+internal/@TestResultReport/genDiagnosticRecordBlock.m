function docPart=genDiagnosticRecordBlock(reportObj,diagnosticRecord)














    p=inputParser;
    addRequired(p,'obj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{}));
    addRequired(p,'result',...
    @(x)validateattributes(x,{'sltest.testmanager.DiagnosticRecord'},{}));
    p.parse(reportObj,diagnosticRecord);

    import mlreportgen.dom.*;


    docPart=Group();


    addHeader(docPart,reportObj);


    infoTable=createTable(reportObj);


    addOutcomeRow(reportObj,diagnosticRecord,infoTable);


    addEventRow(reportObj,diagnosticRecord,infoTable);


    append(docPart,infoTable);


    addReport(docPart,reportObj,diagnosticRecord);
end

function addHeader(docPart,reportObj)
    import mlreportgen.dom.*;
    text=Text(getString(message('stm:ReportContent:DiagnosticRecordHeader')));
    sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.BodyFontName,...
    reportObj.BodyFontSize,reportObj.BodyFontColor,false,false);
    para=Paragraph();
    append(para,text);
    para.OuterLeftMargin=reportObj.ChapterIndentL2;
    append(docPart,para);
end

function infoTable=createTable(reportObj)
    import mlreportgen.dom.*;
    infoTable=FormalTable(2);
    infoTable.TableEntriesStyle={OuterMargin('0mm')};
    infoTable.Style=[infoTable.Style,{ResizeToFitContents(false),...
    OuterMargin(reportObj.ChapterIndentL2,'0mm','0mm','2mm')}];
    groups=sltest.testmanager.ReportUtility.genTableColSpecGroup([{'5cm'},{'10cm'}]);
    infoTable.ColSpecGroups=groups;
end

function addOutcomeRow(reportObj,diagnosticRecord,infoTable)
    import mlreportgen.dom.*;
    text=Text(getString(message('stm:ReportContent:DiagnosticRecordOutcome')));
    sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.BodyFontName,...
    reportObj.BodyFontSize,reportObj.BodyFontColor,false,false);
    entry=TableEntry(Paragraph(text));
    onerow=TableRow();
    onerow.append(entry);

    text=Text(char(diagnosticRecord.Outcome));
    if diagnosticRecord.Outcome==sltest.testmanager.TestResultOutcomes.Failed
        outcomeColor='Red';
    else
        outcomeColor=reportObj.BodyFontColor;
    end
    sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.BodyFontName,...
    reportObj.BodyFontSize,outcomeColor,false,false);
    entry=TableEntry(Paragraph(text));
    onerow.append(entry);
    infoTable.append(onerow);
end

function addEventRow(reportObj,diagnosticRecord,infoTable)
    import mlreportgen.dom.*;
    text=Text(getString(message('stm:ReportContent:DiagnosticRecordEvent')));
    sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.BodyFontName,...
    reportObj.BodyFontSize,reportObj.BodyFontColor,false,false);
    entry=TableEntry(Paragraph(text));
    onerow=TableRow();
    onerow.append(entry);

    text=Text(diagnosticRecord.Event);
    sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.BodyFontName,...
    reportObj.BodyFontSize,reportObj.BodyFontColor,false,false);
    entry=TableEntry(Paragraph(text));
    onerow.append(entry);
    infoTable.append(onerow);
end

function addReport(docPart,reportObj,diagnosticRecord)
    import mlreportgen.dom.*;
    para=Paragraph();
    para.OuterLeftMargin=reportObj.ChapterIndentL2;
    para.Style=[para.Style,{WhiteSpace('pre')}];
    text=Text(diagnosticRecord.Report);
    sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.BodyFixedWidthFontName,...
    reportObj.BodyFixedWidthFontSize,reportObj.BodyFontColor,false,false);
    append(para,text);
    append(docPart,para);
end
