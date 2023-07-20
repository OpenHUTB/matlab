function baselineTable=genBaselineInfoTable(reportObj,resultObj)













    p=inputParser;
    addRequired(p,'reportObj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{}));
    addRequired(p,'resultObj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestCaseResult',...
    'sltest.testmanager.TestIterationResult'},{}));
    p.parse(reportObj,resultObj);

    import mlreportgen.dom.*;

    baselineData=resultObj.Baseline;

    baselineTable=FormalTable(2);
    baselineTable.TableEntriesStyle={OuterMargin('0mm')};
    baselineTable.Style=[baselineTable.Style,{ResizeToFitContents(false),...
    OuterMargin(reportObj.ChapterIndentL2,'0mm','0mm','2mm')}];

    groups=sltest.testmanager.ReportUtility.genTableColSpecGroup([{'4cm'},{'10cm'}]);
    baselineTable.ColSpecGroups=groups;

    onerow=TableRow();
    str=getString(message('stm:ReportContent:Label_BaselineInformation'));
    text=Text(str);
    sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.BodyFontName,reportObj.BodyFontSize,reportObj.BodyFontColor,true,false);
    entryPara=Paragraph(text);
    entry=TableEntry(entryPara);
    entry.ColSpan=2;
    onerow.append(entry);
    onerow.Style={RowHeight('0.3in')};
    baselineTable.append(onerow);

    strList1={getString(message('stm:ReportContent:Field_BaselineName'))};
    strList2={baselineData.BaselineName};

    strList1=[strList1,{getString(message('stm:ReportContent:Field_BaselineFile'))}];
    strList2=[strList2,{baselineData.BaselineFile}];

    for k=1:length(strList1)
        onerow=TableRow();

        text=Text(strList1{k});
        sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.BodyFontName,reportObj.BodyFontSize,reportObj.BodyFontColor,false,false);
        entryPara=Paragraph(text);
        entry=TableEntry(entryPara);
        onerow.append(entry);

        text=Text(strList2{k});
        sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.BodyFontName,reportObj.BodyFontSize,reportObj.BodyFontColor,false,false);
        entryPara=Paragraph(text);
        entry=TableEntry(entryPara);
        onerow.append(entry);
        baselineTable.append(onerow);
    end
end
