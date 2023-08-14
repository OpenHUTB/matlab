function groupObj=genSignalSummaryTable(obj,signalList,isComparison,isSummaryTable)
















    p=inputParser;
    addRequired(p,'obj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{}));
    addRequired(p,'signalList',...
    @(x)validateattributes(x,{'sltest.testmanager.ReportUtility.Signal'},...
    {'2d'}));
    addRequired(p,'isComparison',@(x)validateattributes(x,{'logical'},{'scalar'}));
    addRequired(p,'isSummaryTable',@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.parse(obj,signalList,isComparison,isSummaryTable);

    import mlreportgen.dom.*;

    groupObj=Group();

    if isempty(signalList)
        return;
    end

    runID=signalList(1).TopSignal.runID;
    if(strcmp(obj.reportType,'html'))
        if(isComparison)
            columnWidth=[{'5cm'},{'2cm'},{'2cm'},{'2cm'},{'2cm'},{'2cm'},{'2cm'},{'2cm'},...
            {'3cm'},{'3cm'},{'2cm'},{'3cm'},{'2cm'},{'2cm'}];
        else
            columnWidth=[{'5cm'},{'3cm'},{'3cm'},{'3cm'},{'3cm'},{'3cm'}];
        end
    else
        if(isComparison)
            columnWidth=[{'2cm'},{''},{''},{''},{''},{''},...
            {''},{''},{''},{''},{''},{''},{''},{''}];
        else
            columnWidth=[{'3cm'},{''},{''},{''},{''},{''}];
        end
    end

    needLinksToFigure=(isSummaryTable&&(~isComparison||obj.IncludeComparisonSignalPlots));

    if(needLinksToFigure)
        columnWidth=[columnWidth,{'1.5cm'}];
    end
    signalSummaryTable=FormalTable(length(columnWidth));
    signalSummaryTable=setStyleForSignalSummaryTable(obj,signalSummaryTable);
    groups=sltest.testmanager.ReportUtility.genTableColSpecGroup(columnWidth);
    signalSummaryTable.ColSpecGroups=groups;
    signalSummaryTable.Style=[signalSummaryTable.Style,{ResizeToFitContents(true),Width('19cm')}];
    signalSummaryTable.OuterLeftMargin='0cm';
    if(strcmp(obj.reportType,'html'))
        signalSummaryTable.OuterLeftMargin=obj.ChapterIndentL3;
    else
        signalSummaryTable.Width='100%';
    end


    entryList=genHeadRowForSignalSummaryTable(obj,isComparison,needLinksToFigure);
    headrow=TableRow();
    for k=1:length(entryList)
        headrow.append(entryList(k));
    end
    signalSummaryTable.append(headrow);

    for sigIdx=1:length(signalList)
        onerow=TableRow();
        entryList=genTableEntriesForSignalSummary(obj,signalList(sigIdx),isComparison,needLinksToFigure);
        for k=1:length(entryList)
            onerow.append(entryList(k));
        end
        signalSummaryTable.append(onerow);
    end
    if(isSummaryTable)
        linkTargetId=sprintf('Run%d',runID);
        signalSummaryTable.Body.entry(1,1).Children(1).append(LinkTarget(linkTargetId));
    else
        for i=1:length(signalList)
            linkTargetId=sprintf('signal%d',signalList(i).TopSignal.id);
            signalSummaryTable.Body.entry(i,1).Children(1).append(LinkTarget(linkTargetId));
        end
    end
    append(groupObj,signalSummaryTable);
    if(isSummaryTable)
        append(groupObj,sltest.testmanager.ReportUtility.vspace(obj.SectionSpacing));
    end
end


function newTable=setStyleForSignalSummaryTable(obj,table)
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


function entryList=genHeadRowForSignalSummaryTable(obj,isComparison,needLinksToFigure)
    import mlreportgen.dom.*;

    entryList=[];

    fieldNames={};
    fieldNames=[fieldNames,{getString(message('stm:ReportContent:Label_Name'))}];
    if(isComparison)
        fieldNames=[fieldNames,{getString(message('stm:ReportContent:Label_AbsTol'))}];
        fieldNames=[fieldNames,{getString(message('stm:ReportContent:Label_RelTol'))}];
        fieldNames=[fieldNames,{getString(message('stm:ReportContent:Label_LeadingTol'))}];
        fieldNames=[fieldNames,{getString(message('stm:ReportContent:Label_LaggingTol'))}];
        fieldNames=[fieldNames,{getString(message('stm:ResultsTree:MaxDiff'))}];

        fieldNames=[fieldNames,{getString(message('stm:ResultsTree:DataType1'))}];
        fieldNames=[fieldNames,{getString(message('stm:ResultsTree:Units1'))}];
        fieldNames=[fieldNames,{getString(message('stm:ResultsTree:SampleTime1'))}];

        fieldNames=[fieldNames,{getString(message('stm:ResultsTree:DataType2'))}];
        fieldNames=[fieldNames,{getString(message('stm:ResultsTree:Units2'))}];
        fieldNames=[fieldNames,{getString(message('stm:ResultsTree:SampleTime2'))}];
    else
        fieldNames=[fieldNames,{getString(message('stm:ResultsTree:DataType'))}];
        fieldNames=[fieldNames,{getString(message('stm:ResultsTree:Units'))}];
        fieldNames=[fieldNames,{getString(message('stm:ResultsTree:SampleTime'))}];
    end
    fieldNames=[fieldNames,{getString(message('stm:ReportContent:Label_Interp'))}];
    fieldNames=[fieldNames,{getString(message('stm:ReportContent:Label_Sync'))}];

    if(needLinksToFigure)
        fieldNames=[fieldNames,{getString(message('stm:ReportContent:Label_LinkToPlot'))}];
    end

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


function entryList=genTableEntriesForSignalSummary(obj,oneSignal,isComparison,needLinksToFigure)
    import mlreportgen.dom.*;

    entryList=[];

    if(isComparison)
        hasValidSignal=locHasValidSignal(oneSignal);
    else
        hasValidSignal=true;
    end

    entryPara=Paragraph();
    entryPara.Style=[entryPara.Style,{WhiteSpace('pre'),OuterMargin('0mm')}];
    repository=sdi.Repository(0);

    if(isComparison)

        if~hasValidSignal
            append(entryPara,getImg(obj.IconFileOutcomeMisaligned));
        else
            sdiEng=Simulink.sdi.Instance.engine;
            withinTol=sdiEng.getSignalIsWithinTol(oneSignal.TopSignal.id);
            if(withinTol)
                append(entryPara,getImg(obj.IconFileOutcomePassed));
            else
                append(entryPara,getImg(obj.IconFileOutcomeFailed));
            end
        end
    else

        isVerify=repository.getSignalMetaData(oneSignal.TopSignal.id,'IsAssessment');
        if isVerify
            outcome=repository.getSignalMetaData(oneSignal.TopSignal.id,'Outcome');
            switch outcome
            case 7

                append(entryPara,getImg(obj.IconFileOutcomeUntested));
            case 2

                append(entryPara,getImg(obj.IconFileOutcomePassed));
            case 3

                append(entryPara,getImg(obj.IconFileOutcomeFailed));
            end
        end
    end


    needKeepWithNext=~needLinksToFigure&&~isComparison;
    text=Text(['  ',oneSignal.TopSignal.signalLabel]);
    text.Style=[text.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
    append(entryPara,text);
    entryPara.Style={KeepWithNext(needKeepWithNext),OuterMargin('2mm','0mm','0mm','0mm')};
    entry=TableEntry(entryPara);
    entry.Style={HAlign('left'),WhiteSpace('pre'),VAlign('middle')};

    entryList=[entryList,entry];

    if(isComparison)

        str=sprintf('%.3g',oneSignal.TopSignal.absTol);
        text=Text(str);
        text.Style=[text.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
        entryPara=Paragraph(text);
        entryPara.Style={KeepWithNext(needKeepWithNext),OuterMargin('0mm')};
        entry=TableEntry(entryPara);
        entry.Style={HAlign('center'),VAlign('middle')};
        entryList=[entryList,entry];


        str=sprintf('%.3g',oneSignal.TopSignal.relTol);
        text=Text(str);
        text.Style=[text.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
        entryPara=Paragraph(text);
        entryPara.Style={KeepWithNext(needKeepWithNext),OuterMargin('0mm')};
        entry=TableEntry(entryPara);
        entry.Style={HAlign('center'),VAlign('middle')};
        entryList=[entryList,entry];


        str=sprintf('%.3g',sltest.testmanager.ReportUtility.Signal.getLeadingTolerance(oneSignal.TopSignal));
        text=Text(str);
        text.Style=[text.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
        entryPara=Paragraph(text);
        entryPara.Style={KeepWithNext(needKeepWithNext),OuterMargin('0mm')};
        entry=TableEntry(entryPara);
        entry.Style={HAlign('center'),VAlign('middle')};
        entryList=[entryList,entry];


        str=sprintf('%.3g',sltest.testmanager.ReportUtility.Signal.getLaggingTolerance(oneSignal.TopSignal));
        text=Text(str);
        text.Style=[text.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
        entryPara=Paragraph(text);
        entryPara.Style={KeepWithNext(needKeepWithNext),OuterMargin('0mm')};
        entry=TableEntry(entryPara);
        entry.Style={HAlign('center'),VAlign('middle')};
        entryList=[entryList,entry];


        maxDiff=repository.getSignalMetric(oneSignal.TopSignal.id,'MaxDifference');
        str=sprintf('%.3g',maxDiff);
        text=Text(str);
        text.Style=[text.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
        entryPara=Paragraph(text);
        entryPara.Style={KeepWithNext(needKeepWithNext),OuterMargin('0mm')};
        entry=TableEntry(entryPara);
        entry.Style={HAlign('center'),VAlign('middle')};
        entryList=[entryList,entry];


        dataType1='';
        units1='';
        sampleTime1='';
        if(~isempty(oneSignal.Baseline))
            dataType1=repository.getSignalDataTypeLabel(oneSignal.Baseline.id);
            sampleTime1=oneSignal.Baseline.sampleTime;
            units1=oneSignal.Baseline.units;
        end
        text=Text(dataType1);
        text.Style=[text.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
        entryPara=Paragraph(text);
        entryPara.Style={KeepWithNext(needKeepWithNext),OuterMargin('0mm')};
        entry=TableEntry(entryPara);
        entry.Style={HAlign('center'),VAlign('middle')};
        entryList=[entryList,entry];


        text=Text(units1);
        text.Style=[text.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
        entryPara=Paragraph(text);
        entryPara.Style={KeepWithNext(needKeepWithNext),OuterMargin('0mm')};
        entry=TableEntry(entryPara);
        entry.Style={HAlign('center'),VAlign('middle')};
        entryList=[entryList,entry];


        text=Text(sampleTime1);
        text.Style=[text.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
        entryPara=Paragraph(text);
        entryPara.Style={KeepWithNext(needKeepWithNext),OuterMargin('0mm')};
        entry=TableEntry(entryPara);
        entry.Style={HAlign('center'),VAlign('middle')};
        entryList=[entryList,entry];


        dataType2='';
        units2='';
        sampleTime2='';
        if(~isempty(oneSignal.Compare_to))
            dataType2=repository.getSignalDataTypeLabel(oneSignal.Compare_to.id);
            sampleTime2=oneSignal.Compare_to.sampleTime;
            units2=oneSignal.Compare_to.units;
        end
        text=Text(dataType2);
        text.Style=[text.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
        entryPara=Paragraph(text);
        entryPara.Style={KeepWithNext(needKeepWithNext),OuterMargin('0mm')};
        entry=TableEntry(entryPara);
        entry.Style={HAlign('center'),VAlign('middle')};
        entryList=[entryList,entry];


        text=Text(units2);
        text.Style=[text.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
        entryPara=Paragraph(text);
        entryPara.Style={KeepWithNext(needKeepWithNext),OuterMargin('0mm')};
        entry=TableEntry(entryPara);
        entry.Style={HAlign('center'),VAlign('middle')};
        entryList=[entryList,entry];


        text=Text(sampleTime2);
        text.Style=[text.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
        entryPara=Paragraph(text);
        entryPara.Style={KeepWithNext(needKeepWithNext),OuterMargin('0mm')};
        entry=TableEntry(entryPara);
        entry.Style={HAlign('center'),VAlign('middle')};
        entryList=[entryList,entry];
    else

        dataType=repository.getSignalDataTypeLabel(oneSignal.TopSignal.id);
        text=Text(dataType);
        text.Style=[text.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
        entryPara=Paragraph(text);
        entryPara.Style={KeepWithNext(needKeepWithNext),OuterMargin('0mm')};
        entry=TableEntry(entryPara);
        entry.Style={HAlign('center'),VAlign('middle')};
        entryList=[entryList,entry];


        text=Text(oneSignal.TopSignal.units);
        text.Style=[text.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
        entryPara=Paragraph(text);
        entryPara.Style={KeepWithNext(needKeepWithNext),OuterMargin('0mm')};
        entry=TableEntry(entryPara);
        entry.Style={HAlign('center'),VAlign('middle')};
        entryList=[entryList,entry];

        text=Text(oneSignal.TopSignal.sampleTime);
        text.Style=[text.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
        entryPara=Paragraph(text);
        entryPara.Style={KeepWithNext(needKeepWithNext),OuterMargin('0mm')};
        entry=TableEntry(entryPara);
        entry.Style={HAlign('center'),VAlign('middle')};
        entryList=[entryList,entry];
    end


    text=Text(oneSignal.TopSignal.interpMethod);
    text.Style=[text.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
    entryPara=Paragraph(text);
    entryPara.Style={KeepWithNext(needKeepWithNext),OuterMargin('0mm')};
    entry=TableEntry(entryPara);
    entry.Style={HAlign('center'),VAlign('middle')};
    entryList=[entryList,entry];


    text=Text(oneSignal.TopSignal.syncMethod);
    text.Style=[text.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
    entryPara=Paragraph(text);
    entryPara.Style={KeepWithNext(needKeepWithNext),OuterMargin('0mm')};
    entry=TableEntry(entryPara);
    entry.Style={HAlign('center'),VAlign('middle')};
    entryList=[entryList,entry];


    if(needLinksToFigure)
        if~hasValidSignal
            tmpTxt=Text(getString(message('stm:ReportContent:Label_Link')));
            sltest.testmanager.ReportUtility.setTextStyle(tmpTxt,obj.TableFontName,obj.TableFontSize,'Grey',false,false);
            entryPara=Paragraph(tmpTxt);
        else
            tmpId=sprintf('signal%d',oneSignal.TopSignal.id);
            inlnkObj=InternalLink(tmpId,getString(message('stm:ReportContent:Label_Link')));
            tmpTxt=inlnkObj.Children(1);
            sltest.testmanager.ReportUtility.setTextStyle(tmpTxt,obj.TableFontName,obj.TableFontSize,'blue',false,false);
            entryPara=Paragraph(inlnkObj);
        end
        entryPara.Style={KeepWithNext(needKeepWithNext),OuterMargin('0mm')};
        entry=TableEntry(entryPara);
        entry.Style={HAlign('center'),VAlign('middle')};
        entryList=[entryList,entry];
    end
end

function bool=locHasValidSignal(oneSignal)
    bool=false;
    if~isempty(oneSignal.Baseline)&&~isempty(oneSignal.Baseline.dataValues.Data)
        bool=true;
        return;
    end
    if~isempty(oneSignal.Compare_to)&&~isempty(oneSignal.Compare_to.dataValues.Data)
        bool=true;
        return;
    end
    if~isempty(oneSignal.Difference)&&~isempty(oneSignal.Difference.dataValues.Data)
        bool=true;
        return;
    end
    if~isempty(oneSignal.Tolerance)&&~isempty(oneSignal.Tolerance.dataValues.Data)
        bool=true;
        return;
    end
end

function img=getImg(path)
    img=mlreportgen.dom.Image(path);
    sizeStr='12px';
    img.Width=sizeStr;
    img.Height=sizeStr;
end
