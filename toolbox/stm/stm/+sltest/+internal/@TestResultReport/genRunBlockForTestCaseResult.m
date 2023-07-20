function groupObj=genRunBlockForTestCaseResult(obj,run,runType,result,simIndex)

















    p=inputParser;
    addRequired(p,'obj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{}));

    addRequired(p,'run',@(x)validateattributes(x,{'Simulink.sdi.Run','struct'},{}));
    addRequired(p,'runType',@(x)validateattributes(x,{'sltest.testmanager.RunTypes'},{}));
    addRequired(p,'result',...
    @(x)validateattributes(x,{'sltest.testmanager.ReportUtility.ReportResultData'},{}));
    addRequired(p,'simIndex',...
    @(x)validateattributes(x,{'double'},{'integer','scalar','<=',2}));

    p.parse(obj,run,runType,result,simIndex);

    import mlreportgen.dom.*;
    groupObj=Group();
    resultObj=result.Data;
    isComparison=(runType==sltest.testmanager.RunTypes.Comparison);

    showSignals=0;
    if(runType==sltest.testmanager.RunTypes.Comparison||...
        runType==sltest.testmanager.RunTypes.VerifyResults)
        if(obj.IncludeComparisonSignalPlots)
            showSignals=1;
        end
    elseif(obj.IncludeSimulationSignalPlots)
        showSignals=1;
    end
    if(Simulink.sdi.isValidRunID(run.id))
        if(run.SignalCount==0)
            showSignals=0;
        end
    else
        showSignals=0;
    end


    testCaseType=sltest.testmanager.ReportUtility.getTestTypeOfResult(resultObj);

    if(isComparison)

        if(testCaseType==sltest.testmanager.TestCaseTypes.Equivalence)
            titleStr=getString(message('stm:ReportContent:Label_EquivalenceComparison'));
        else
            titleStr=getString(message('stm:ReportContent:Label_BaselineComparison'));
        end
    elseif(runType==sltest.testmanager.RunTypes.Baseline)
        titleStr=resultObj.Baseline.BaselineName;
    elseif(runType==sltest.testmanager.RunTypes.VerifyResults)
        titleStr=getString(message('stm:ReportContent:Label_Verify'));
        if(testCaseType==sltest.testmanager.TestCaseTypes.Equivalence)
            titleStr=sprintf('%s %d',getString(message('stm:ReportContent:Label_Verify')),simIndex);
        end
    elseif(runType==sltest.testmanager.RunTypes.InputRun)
        titleStr=getString(message('stm:ReportContent:Label_InputRun'));
        if(testCaseType==sltest.testmanager.TestCaseTypes.Equivalence)
            titleStr=sprintf('%s %d',getString(message('stm:ReportContent:Label_InputRun')),simIndex);
        end
    else
        titleStr=getString(message('stm:ReportContent:Label_Simulation'));
        if(testCaseType==sltest.testmanager.TestCaseTypes.Equivalence)
            titleStr=sprintf('%s %d',getString(message('stm:ReportContent:Label_Simulation')),simIndex);
        end
    end
    showTitle=true;


    hasSignals=true;
    if(Simulink.sdi.isValidRunID(run.id))
        if(run.SignalCount==0)
            hasSignals=false;
        end
    else
        hasSignals=false;
    end




    if(runType==sltest.testmanager.RunTypes.Comparison||...
        runType==sltest.testmanager.RunTypes.VerifyResults)
        showTitle=hasSignals;
    end

    if(~isempty(titleStr)&&showTitle)
        text=Text(titleStr);
        sltest.testmanager.ReportUtility.setTextStyle(text,obj.BodyFontName,obj.BodyFontSize,obj.BodyFontColor,true,false);
        p=append(groupObj,Paragraph(text));
        p.Style={KeepWithNext(true),OuterMargin(obj.ChapterIndent,'0mm',obj.SectionSpacing,obj.SectionSpacing)};
    end


    if(runType==sltest.testmanager.RunTypes.Baseline||...
        runType==sltest.testmanager.RunTypes.Simulation||...
        runType==sltest.testmanager.RunTypes.InputRun)

        if(runType==sltest.testmanager.RunTypes.Baseline)
            simCfgTable=obj.genBaselineInfoTable(resultObj);
        elseif(runType==sltest.testmanager.RunTypes.InputRun)
            isExternalInputType=stm.internal.getExternalRunType(run.id);
            simCfgTable=obj.genInputInfoTable(resultObj,isExternalInputType,simIndex);
        else
            simCfgTable=obj.genSimulationConfigurationTable(result,simIndex);
        end
        simCfgTable.OuterLeftMargin=obj.ChapterIndentL2;
        append(groupObj,simCfgTable);
        append(groupObj,sltest.testmanager.ReportUtility.vspace(obj.SectionSpacing));
    end


    if(runType==sltest.testmanager.RunTypes.Simulation...
        &&~isempty(resultObj.ParameterSet(simIndex).ParameterSetName)...
        &&~isempty(resultObj.ParameterSet(simIndex).ParameterOverrides))

        str=getString(message('stm:general:ParameterOverrides'));
        text=Text(str);
        sltest.testmanager.ReportUtility.setTextStyle(text,obj.BodyFontName,obj.BodyFontSize,obj.BodyFontColor,true,false);
        para=sltest.testmanager.ReportUtility.genParaDefaultStyle(text);
        para.Style=[para.Style,{OuterMargin(obj.ChapterIndentL2,'0mm','0mm','0mm')}];
        groupObj.append(para);


        paramOverridesTable=obj.genParameterOverridesTable(resultObj,simIndex);
        append(groupObj,paramOverridesTable);
        append(groupObj,sltest.testmanager.ReportUtility.vspace(obj.SectionSpacing));
    end


    if(obj.IncludeMATLABFigures)
        if(runType==sltest.testmanager.RunTypes.Simulation)
            simCallBackPlotsPart=obj.genSimulationCallbackPlotsBlock(result.Data,simIndex);
            if~isempty(simCallBackPlotsPart)
                append(groupObj,simCallBackPlotsPart);
            end
        end
    end

    if(hasSignals)

        signalList=[];

        if showSignals||runType==sltest.testmanager.RunTypes.VerifyResults||...
            runType==sltest.testmanager.RunTypes.Comparison
            signalList=sltest.testmanager.ReportUtility.getSignalsFromRun(run,runType);
        end


        if(showSignals&&runType==sltest.testmanager.RunTypes.Simulation)
            titleStr=getString(message('stm:ToolTips:LabelSimulationResult'));
            text=Text(titleStr);
            sltest.testmanager.ReportUtility.setTextStyle(text,obj.BodyFontName,...
            obj.BodyFontSize,obj.BodyFontColor,true,false);
            para=sltest.testmanager.ReportUtility.genParaDefaultStyle(text);
            para.Style=[para.Style,{OuterMargin(obj.ChapterIndentL2,'0mm','0mm','0mm')}];
            groupObj.append(para);
        end

        if runType==sltest.testmanager.RunTypes.VerifyResults
            signalSummaryTable=obj.genVerifySummaryTable(signalList,true);
            append(groupObj,signalSummaryTable);
            append(groupObj,sltest.testmanager.ReportUtility.vspace(obj.SectionSpacing));
        else
            if(showSignals||runType==sltest.testmanager.RunTypes.Comparison)

                signalSummaryTable=obj.genSignalSummaryTable(signalList,isComparison,true);
                append(groupObj,signalSummaryTable);
                append(groupObj,sltest.testmanager.ReportUtility.vspace(obj.SectionSpacing));
            end
        end
        if(showSignals)

            for sigIdx=1:length(signalList)
                if(isComparison)
                    nValidSignals=0;
                    if(~isempty(signalList(sigIdx).Baseline)&&~isempty(signalList(sigIdx).Baseline.dataValues.Data))
                        nValidSignals=nValidSignals+1;
                    end
                    if(~isempty(signalList(sigIdx).Compare_to)&&~isempty(signalList(sigIdx).Compare_to.dataValues.Data))
                        nValidSignals=nValidSignals+1;
                    end
                    if(~isempty(signalList(sigIdx).Difference)&&~isempty(signalList(sigIdx).Difference.dataValues.Data))
                        nValidSignals=nValidSignals+1;
                    end
                    if(~isempty(signalList(sigIdx).Tolerance)&&~isempty(signalList(sigIdx).Tolerance.dataValues.Data))
                        nValidSignals=nValidSignals+1;
                    end
                    if(~isempty(signalList(sigIdx).LowerTolerance)&&~isempty(signalList(sigIdx).LowerTolerance.dataValues.Data))
                        nValidSignals=nValidSignals+1;
                    end
                    if(~isempty(signalList(sigIdx).UpperTolerance)&&~isempty(signalList(sigIdx).UpperTolerance.dataValues.Data))
                        nValidSignals=nValidSignals+1;
                    end
                else
                    nValidSignals=1;
                end
                if(nValidSignals>0&&isComparison)
                    if runType==sltest.testmanager.RunTypes.VerifyResults
                        signalTitleTable=obj.genVerifySummaryTable(signalList(sigIdx),false);
                    else
                        signalTitleTable=obj.genSignalSummaryTable(signalList(sigIdx),...
                        isComparison,false);
                    end
                    append(groupObj,signalTitleTable);
                    tmpName=sprintf('plot_%d.png',signalList(sigIdx).TopSignal.id);
                    imageFilePath=fullfile(obj.workingPath,tmpName);
                    obj.plotOneSignalToFile(imageFilePath,signalList(sigIdx));
                    para=sltest.testmanager.ReportUtility.genImageParagraph(imageFilePath,obj.SignalPlotWidth,obj.SignalPlotHeight);
                    append(groupObj,para);

                    obj.ReportGenStatus=obj.getReportGenerationStatus();
                    if(obj.ReportGenStatus>=2)
                        break;
                    end
                    createNavigationLinksForPlots(obj,isComparison,run,groupObj);
                end
            end




            if(~isComparison)
                numPagesOfPlots=ceil(length(signalList)/(obj.NumPlotRowsPerPage*obj.NumPlotColumnsPerPage));
                lastPlottedSigIdx=0;

                for idx=1:numPagesOfPlots
                    firstSigIdxInPage=lastPlottedSigIdx+1;
                    lastSigIdxInPage=lastPlottedSigIdx+(obj.NumPlotRowsPerPage*obj.NumPlotColumnsPerPage);
                    if(lastSigIdxInPage>length(signalList))
                        lastSigIdxInPage=length(signalList);
                    end
                    if runType==sltest.testmanager.RunTypes.VerifyResults
                        signalTitleTable=obj.genVerifySummaryTable(signalList(firstSigIdxInPage:lastSigIdxInPage),false);
                    else
                        signalTitleTable=obj.genSignalSummaryTable(signalList(firstSigIdxInPage:lastSigIdxInPage),...
                        isComparison,false);
                    end
                    append(groupObj,signalTitleTable);
                    tmpName=sltest.testmanager.ReportUtility.getTempNameFromRun(run,idx,runType);
                    imageFilePath=fullfile(obj.workingPath,tmpName);
                    obj.plotMultipleSignals(imageFilePath,signalList,obj.NumPlotRowsPerPage,obj.NumPlotColumnsPerPage,lastPlottedSigIdx);
                    lastPlottedSigIdx=idx*(obj.NumPlotRowsPerPage*obj.NumPlotColumnsPerPage);
                    para=sltest.testmanager.ReportUtility.genImageParagraph(imageFilePath,obj.SignalPlotWidth,obj.SignalPlotHeight);
                    append(groupObj,para);
                    obj.ReportGenStatus=obj.getReportGenerationStatus();
                    if(obj.ReportGenStatus>=2)
                        break;
                    end
                    createNavigationLinksForPlots(obj,isComparison,run,groupObj);
                end
            end
        end
    end


    if(obj.IncludeErrorMessages&&runType==sltest.testmanager.RunTypes.Simulation)
        logMSGs=resultObj.LogMessages.Simulation(simIndex).messages;
        errorMSGs=resultObj.ErrorMessages.Simulation(simIndex).messages;
        if(~isempty(logMSGs))
            tmpName=getString(message('stm:ReportContent:Field_SimulationLogs'));
            msgPart=sltest.testmanager.ReportUtility.genMessageBlock(obj,logMSGs,tmpName,'Black',obj.ChapterIndent);
            append(groupObj,msgPart);
            append(groupObj,sltest.testmanager.ReportUtility.vspace(obj.SectionSpacing));
        end
        if(~isempty(errorMSGs))
            tmpName=getString(message('stm:ReportContent:Field_SimulationError'));
            msgPart=sltest.testmanager.ReportUtility.genMessageBlock(obj,errorMSGs,tmpName,'Red',obj.ChapterIndent);
            append(groupObj,msgPart);
            append(groupObj,sltest.testmanager.ReportUtility.vspace(obj.SectionSpacing));
        end

        if(~isempty(logMSGs)||~isempty(errorMSGs))
            linkPara=obj.genHyperLinkToToC(obj.ChapterIndentL2);
            append(groupObj,linkPara);
            append(groupObj,sltest.testmanager.ReportUtility.vspace(obj.SectionSpacing));
        end
    end
end

function createNavigationLinksForPlots(obj,isComparison,run,docPart)

    import mlreportgen.dom.*;

    table=Table(2);
    table.TableEntriesStyle={OuterMargin('0in')};
    table.Style=[table.Style,{OuterMargin(obj.ChapterIndent,'0mm','0mm','2mm')}];

    onerow=TableRow();
    inlnkObj=InternalLink(obj.tocLinkTargetName,getString(message('stm:ReportContent:Label_BackToReportSummary')));
    tmpTxt=inlnkObj.Children(1);
    sltest.testmanager.ReportUtility.setTextStyle(tmpTxt,obj.BodyFontName,obj.BodyFontSize,'blue',false,false);
    entry=TableEntry(Paragraph(inlnkObj));
    entry.append(Paragraph(Text(' ')));
    onerow.append(entry);

    IDForSigTable=sprintf('Run%d',run.id);
    if(isComparison)
        inlnkObj=InternalLink(IDForSigTable,getString(message('stm:ReportContent:Label_BackToCriteriaResults')));
    else
        inlnkObj=InternalLink(IDForSigTable,getString(message('stm:ReportContent:Label_BackToSignalSummary')));
    end
    tmpTxt=inlnkObj.Children(1);
    sltest.testmanager.ReportUtility.setTextStyle(tmpTxt,obj.BodyFontName,obj.BodyFontSize,'blue',false,false);
    onerow.append(TableEntry(Paragraph(inlnkObj)));

    table.append(onerow);
    table.Style=[table.Style,{OuterMargin(obj.ChapterIndentL3,'0mm','4mm','2mm')}];
    append(docPart,table);
    append(docPart,sltest.testmanager.ReportUtility.vspace(obj.SectionSpacing));

end
