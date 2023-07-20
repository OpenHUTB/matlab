function docPart=genAssessmentsSummaryTable(obj,assessmentList)













    p=inputParser;
    addRequired(p,'obj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{}));
    addRequired(p,'result');

    p.parse(obj,assessmentList);

    import mlreportgen.dom.*;

    docPart=Group();


    if isempty(assessmentList)
        return;
    end

    columnWidth=[{'3cm'},{'14cm'}];
    assessmentsSummaryTable=FormalTable(length(columnWidth));
    assessmentsSummaryTable=setStyleForAssessmentsSummaryTable(obj,assessmentsSummaryTable);
    groups=sltest.testmanager.ReportUtility.genTableColSpecGroup(columnWidth);
    assessmentsSummaryTable.ColSpecGroups=groups;
    assessmentsSummaryTable.Style=[assessmentsSummaryTable.Style,{ResizeToFitContents(true),Width('19cm')}];
    assessmentsSummaryTable.OuterLeftMargin='0cm';
    if(strcmp(obj.reportType,'html'))
        assessmentsSummaryTable.OuterLeftMargin=obj.ChapterIndentL3;
    else
        assessmentsSummaryTable.Width='100%';
    end


    entryList=genHeadRowForAssessmentsSummaryTable(obj);
    headrow=TableRow();
    for k=1:length(entryList)
        headrow.append(entryList(k));
    end
    assessmentsSummaryTable.append(headrow);

    for idx=1:length(assessmentList)
        onerow=TableRow();
        entryList=genTableEntriesForAssessmentSummary(obj,assessmentList(idx));
        for k=1:length(entryList)
            onerow.append(entryList(k));
        end
        assessmentsSummaryTable.append(onerow);
    end

    append(docPart,assessmentsSummaryTable);
    append(docPart,sltest.testmanager.ReportUtility.vspace(obj.SectionSpacing));
end



function newTable=setStyleForAssessmentsSummaryTable(obj,table)
    import mlreportgen.dom.*;

    table.TableEntriesStyle={OuterMargin('0in'),KeepWithNext(true)};
    table.Style=[table.Style,{ResizeToFitContents(false),...
    OuterMargin(obj.ChapterIndent,'0mm','0mm','0mm')}];

    table.Border='solid';
    table.BorderWidth='1pt';
    table.BorderColor='AliceBlue';
    table.RowSep='dashed';
    table.RowSepColor='grey';
    table.RowSepWidth='1pt';
    table.ColSep='dashed';
    table.ColSepColor='grey';
    table.ColSepWidth='1pt';
    newTable=table;
end



function entryList=genHeadRowForAssessmentsSummaryTable(obj)
    import mlreportgen.dom.*;

    entryList=[];

    fieldNames={};
    fieldNames=[fieldNames,{getString(message('stm:ReportContent:Label_Name'))}];
    fieldNames=[fieldNames,{getString(message('sltest:assessments:editor:AssessmentLabel'))}];
    for k=1:length(fieldNames)
        label=Text(fieldNames{k});
        sltest.testmanager.ReportUtility.setTextStyle(label,obj.TableFontName,obj.TableFontSize,obj.TableFontColor,true,false);
        entryPara=sltest.testmanager.ReportUtility.genParaDefaultStyle(label);
        entryPara.Style={KeepWithNext(true),OuterMargin('0mm')};

        entry=TableEntry(entryPara);
        entry.Style={BackgroundColor('DarkGray'),HAlign('center'),VAlign('middle')};
        entryList=[entryList,entry];%#ok<AGROW>
    end
end




function entryList=genTableEntriesForAssessmentSummary(obj,oneAssessment)
    import mlreportgen.dom.*;

    entryList=[];


    imgY=Image(obj.IconFileOutcomePassed);
    imgN=Image(obj.IconFileOutcomeFailed);
    imgX=Image(obj.IconFileOutcomeMisaligned);
    imgU=Image(obj.IconFileOutcomeUntested);

    sizeStr='12px';
    imgY.Width=sizeStr;
    imgY.Height=sizeStr;

    imgN.Width=sizeStr;
    imgN.Height=sizeStr;

    imgX.Width=sizeStr;
    imgX.Height=sizeStr;

    imgU.Width=sizeStr;
    imgU.Height=sizeStr;

    entryPara=Paragraph();
    entryPara.Style=[entryPara.Style,{WhiteSpace('pre'),OuterMargin('0mm')}];


    switch oneAssessment.Outcome
    case sltest.testmanager.TestResultOutcomes.Untested

        append(entryPara,imgU);
    case sltest.testmanager.TestResultOutcomes.Passed

        append(entryPara,imgY);
    case sltest.testmanager.TestResultOutcomes.Failed

        append(entryPara,imgN);
    end


    text=Text(['  ',oneAssessment.Name]);
    text.Style=[text.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
    append(entryPara,text);
    entryPara.Style={KeepWithNext(true),OuterMargin('2mm','0mm','1mm','0mm')};
    entry=TableEntry(entryPara);
    entry.Style={HAlign('left'),WhiteSpace('pre'),VAlign('middle')};
    entryList=[entryList,entry];


    text=Text(oneAssessment.Label);
    text.Style=[text.Style,{FontSize('9pt'),Color(obj.TableFontColor)}];
    entryPara=Paragraph(text);
    entryPara.Style={KeepWithNext(true),OuterMargin('2mm','0mm','1mm','2mm')};
    entry=TableEntry(entryPara);
    entry.Style={HAlign('left'),VAlign('middle')};

    if obj.IncludeTestRequirement
        genAssessmentsRequirementsTable(obj,oneAssessment,entry);
    end

    entryList=[entryList,entry];
end

function genAssessmentsRequirementsTable(obj,oneAssessment,entry)
    import mlreportgen.dom.*;

    reqs=oneAssessment.Requirements;
    if isempty(reqs)
        return;
    end

    sectionHeading=Text(getString(message('stm:ReportContent:Label_TestAssessmentsRequirement')));
    sectionHeading.Style=[sectionHeading.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
    sectionHeading.Bold=true;
    headingPara=Paragraph(sectionHeading);
    headingPara.Style={KeepWithNext(true),OuterMargin('2mm','0mm','0mm','0mm')};
    append(entry,headingPara);

    for i=1:length(reqs)
        descLabel=Text([getString(message('stm:ReportContent:Field_Description')),' ']);
        descLabel.Style=[sectionHeading.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
        descLabel.Bold=true;
        descPara=Paragraph(descLabel);
        descPara.Style={KeepWithNext(true),OuterMargin('2mm','0mm','0mm','0mm')};
        descValue=Text(reqs(i).description);
        descValue.Style=[sectionHeading.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
        descValue.Bold=false;
        append(descPara,descValue);
        append(entry,descPara);

        docLabel=Text([getString(message('stm:ReportContent:Field_Document')),' ']);
        docLabel.Style=[sectionHeading.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
        docLabel.Bold=true;
        docPara=Paragraph(docLabel);
        docPara.Style={KeepWithNext(true),OuterMargin('2mm','0mm','0mm','1mm')};
        docValue=Text(reqs(i).doc);
        docValue.Style=[sectionHeading.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
        docValue.Bold=false;
        if~isempty(reqs(i).docurl)
            docLink=ExternalLink(reqs(i).docurl,docValue);
            append(docPara,docLink);
        else
            append(docPara,docValue);
        end
        append(entry,docPara);
    end
end
