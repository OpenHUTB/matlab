function inputTable=genInputInfoTable(reportObj,resultObj,isExternalInputType,simIndex)













    p=inputParser;
    addRequired(p,'reportObj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{}));
    addRequired(p,'resultObj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestCaseResult',...
    'sltest.testmanager.TestIterationResult'},{}));
    p.parse(reportObj,resultObj);

    import mlreportgen.dom.*;

    inputTable=FormalTable(2);
    inputTable.TableEntriesStyle={OuterMargin('0mm')};
    inputTable.Style=[inputTable.Style,{ResizeToFitContents(false),...
    OuterMargin(reportObj.ChapterIndentL2,'0mm','0mm','2mm')}];

    groups=sltest.testmanager.ReportUtility.genTableColSpecGroup([{'4cm'},{'10cm'}]);
    inputTable.ColSpecGroups=groups;

    onerow=TableRow();
    str=getString(message('stm:ReportContent:Label_InputInformation'));
    text=Text(str);
    sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.BodyFontName,reportObj.BodyFontSize,reportObj.BodyFontColor,true,false);
    entryPara=Paragraph(text);
    entry=TableEntry(entryPara);
    entry.ColSpan=2;
    onerow.append(entry);
    onerow.Style={RowHeight('0.3in')};
    inputTable.append(onerow);

    if(isExternalInputType)
        strList1={getString(message('stm:ReportContent:Field_ExternalInputName'))};
        strList1=[strList1,{getString(message('stm:ReportContent:Field_ExternalInputFile'))}];

        strList2={resultObj.ExternalInput(simIndex).ExternalInputName};
        strList2=[strList2,{resultObj.ExternalInput(simIndex).ExternalInputFile}];
    else
        [strList1,strList2]=sltest.internal.TestResultReport.getSignalBuilderOrEditor(resultObj.SignalBuilderGroup(simIndex),'','');
    end

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
        inputTable.append(onerow);
    end
end
