function reqTable=genRequirementLinksTable(reportObj,resultObj,isTestSuiteResult)














    p=inputParser;
    addRequired(p,'reportObj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{}));
    addRequired(p,'resultObj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResult'},{}));
    addRequired(p,'isTestSuiteResult',...
    @(x)validateattributes(x,{'logical'},{'scalar'}));
    p.parse(reportObj,resultObj,isTestSuiteResult);

    import mlreportgen.dom.*;

    Requirements=resultObj.Requirements;
    NReqs=length(Requirements);

    reqTable=FormalTable(2);
    groups=sltest.testmanager.ReportUtility.genTableColSpecGroup([{'1.2in'},{'5in'}]);
    reqTable.ColSpecGroups=groups;
    reqTable.Style={ResizeToFitContents(false),Width('6.5in'),...
    OuterMargin(reportObj.ChapterIndent,'0mm','0mm','2mm')};

    onerow=TableRow();
    if(isTestSuiteResult)
        str=getString(message('stm:ReportContent:Label_TestSuiteRequirement'));
    else
        str=getString(message('stm:ReportContent:Label_TestCaseRequirement'));
    end
    text=Text(str);
    sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.BodyFontName,reportObj.BodyFontSize,reportObj.BodyFontColor,true,false);
    entryPara=sltest.testmanager.ReportUtility.genParaDefaultStyle(text);
    entry=TableEntry(entryPara);
    entry.ColSpan=2;
    onerow.append(entry);
    append(reqTable,onerow);

    fieldList={getString(message('stm:ReportContent:Field_Description')),...
    getString(message('stm:ReportContent:Field_Document'))};
    urlFlag=[0,1];
    for reqIdx=1:NReqs
        valueList={Requirements(reqIdx).description,...
        Requirements(reqIdx).doc};
        for rowIdx=1:length(fieldList)
            onerow=TableRow();


            label=Text(fieldList{rowIdx});
            sltest.testmanager.ReportUtility.setTextStyle(label,reportObj.BodyFontName,reportObj.BodyFontSize,reportObj.BodyFontColor,false,false);
            para=sltest.testmanager.ReportUtility.genParaDefaultStyle(label);
            onerow.append(TableEntry(para));


            label=Text(valueList{rowIdx});
            sltest.testmanager.ReportUtility.setTextStyle(label,reportObj.BodyFontName,reportObj.BodyFontSize,reportObj.BodyFontColor,false,false);
            if(urlFlag(rowIdx)&&~isempty(Requirements(reqIdx).docurl))
                if(isa(resultObj,'sltest.testmanager.TestCaseResult')||isa(resultObj,'sltest.testmanager.TestIterationResult'))
                    testFilePath=resultObj.TestFilePath;
                else
                    tsrProps=stm.internal.getTestSuiteResultDetails(resultObj.getID);
                    testFilePath=tsrProps.testFileLocation;
                end
                if(isequal(reportObj.Doc.Type,'HTML'))
                    docLink=sltest.testmanager.ReportUtility.getRequirementsLink(Requirements(reqIdx),testFilePath);
                else
                    docLink=Text(Requirements(reqIdx).doc);
                end
                para=sltest.testmanager.ReportUtility.genParaDefaultStyle(docLink);
            else
                para=sltest.testmanager.ReportUtility.genParaDefaultStyle(label);
            end
            onerow.append(TableEntry(para));
            append(reqTable,onerow);
        end


        if(reqIdx<NReqs)
            onerow=TableRow();
            para=sltest.testmanager.ReportUtility.vspace('0mm');
            onerow.append(TableEntry(para));

            para=sltest.testmanager.ReportUtility.vspace('0mm');
            onerow.append(TableEntry(para));
            append(reqTable,onerow);
        end
    end
end