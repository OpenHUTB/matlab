function docPart=genVerifySummaryTable(obj,signalList,isSummaryTable)















    p=inputParser;
    addRequired(p,'obj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{}));
    addRequired(p,'signalList',...
    @(x)validateattributes(x,{'sltest.testmanager.ReportUtility.Signal'},...
    {'2d'}));
    addRequired(p,'isSummaryTable',@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.parse(obj,signalList,isSummaryTable);

    import mlreportgen.dom.*;

    docPart=Group();

    if isempty(signalList)
        return;
    end

    runID=signalList(1).TopSignal.runID;
    if(strcmp(obj.reportType,'html'))
        columnWidth=[{'17cm'}];
    else
        columnWidth=[{'17cm'}];
    end
    if(isSummaryTable)
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


    entryList=genHeadRowForSignalSummaryTable(obj,(isSummaryTable&&obj.IncludeComparisonSignalPlots));
    headrow=TableRow();
    for k=1:length(entryList)
        headrow.append(entryList(k));
    end
    signalSummaryTable.append(headrow);

    for sigIdx=1:length(signalList)
        onerow=TableRow();
        if isequal(mod(sigIdx,2),0)
            linkId=sprintf('signal%d',signalList(sigIdx-1).TopSignal.id);
        else
            linkId=sprintf('signal%d',signalList(sigIdx).TopSignal.id);
        end
        entryList=genTableEntriesForSignalSummary(obj,signalList(sigIdx),...
        (isSummaryTable&&obj.IncludeComparisonSignalPlots),linkId);
        for k=1:length(entryList)
            onerow.append(entryList(k));
        end
        signalSummaryTable.append(onerow);
    end

    if(obj.IncludeComparisonSignalPlots)
        if(isSummaryTable)
            linkTargetId=sprintf('Run%d',runID);
        else
            linkTargetId=sprintf('signal%d',signalList(1).TopSignal.id);
        end
        signalSummaryTable.Body.entry(1,1).Children(1).append(LinkTarget(linkTargetId));
    end

    append(docPart,signalSummaryTable);
    if(isSummaryTable)
        append(docPart,sltest.testmanager.ReportUtility.vspace(obj.SectionSpacing));
    end
end



function newTable=setStyleForSignalSummaryTable(obj,table)
    import mlreportgen.dom.*;

    table.TableEntriesStyle={OuterMargin('0in'),KeepWithNext(false)};
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



function entryList=genHeadRowForSignalSummaryTable(obj,needLinksToFigure)
    import mlreportgen.dom.*;

    entryList=[];

    fieldNames={};
    fieldNames=[fieldNames,{getString(message('stm:ReportContent:Label_Name'))}];

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




function entryList=genTableEntriesForSignalSummary(obj,oneSignal,needLinksToFigure,linkId)
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

    nValidSignals=1;

    entryPara=Paragraph();
    entryPara.Style=[entryPara.Style,{WhiteSpace('pre'),OuterMargin('2mm','0mm','0mm','0mm'),KeepWithNext(false)}];
    repository=sdi.Repository(0);



    isVerify=repository.getSignalMetaData(oneSignal.TopSignal.id,'IsAssessment');
    if isVerify
        outcome=repository.getSignalMetaData(oneSignal.TopSignal.id,'Outcome');
        switch outcome
        case 7

            append(entryPara,imgU);
        case 2

            append(entryPara,imgY);
        case 3

            append(entryPara,imgN);
        end
    end


    text=Text(['  ',oneSignal.TopSignal.signalLabel]);
    text.Style=[text.Style,{FontSize(obj.TableFontSize),Color(obj.TableFontColor)}];
    append(entryPara,text);
    entry=TableEntry(entryPara);
    entry.Style={HAlign('left'),WhiteSpace('pre'),VAlign('middle')};

    entryList=[entryList,entry];


    if(needLinksToFigure)
        if(nValidSignals==0)
            tmpTxt=Text(getString(message('stm:ReportContent:Label_Link')));
            sltest.testmanager.ReportUtility.setTextStyle(tmpTxt,obj.TableFontName,obj.TableFontSize,'Grey',false,false);
            entryPara=Paragraph(tmpTxt);
        else
            inlnkObj=InternalLink(linkId,getString(message('stm:ReportContent:Label_Link')));
            tmpTxt=inlnkObj.Children(1);
            sltest.testmanager.ReportUtility.setTextStyle(tmpTxt,obj.TableFontName,obj.TableFontSize,'blue',false,false);
            entryPara=Paragraph(inlnkObj);
        end
        entryPara.Style={KeepWithNext(false),OuterMargin('0mm')};
        entry=TableEntry(entryPara);
        entry.Style={HAlign('center'),VAlign('middle')};
        entryList=[entryList,entry];
    end
end
