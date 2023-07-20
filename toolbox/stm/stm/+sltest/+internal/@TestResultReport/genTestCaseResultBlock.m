function groupObj=genTestCaseResultBlock(obj,result)














    p=inputParser;
    addRequired(p,'obj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{}));
    addRequired(p,'result',...
    @(x)validateattributes(x,{'sltest.testmanager.ReportUtility.ReportResultData'},{}));
    p.parse(obj,result);


    import mlreportgen.dom.*;
    groupObj=Group();
    testCaseResultMetaBlk=obj.genMetadataBlockForTestResult(result,false);
    append(groupObj,testCaseResultMetaBlk);


    if(obj.IncludeCoverageResult==true&&isempty(result.ParentResultName))
        table=obj.genCoverageTable(result.Data);
        append(groupObj,table);
    end

    resultObj=result.Data;
    if(resultObj.Outcome==sltest.testmanager.TestResultOutcomes.Disabled)

        linkPara=obj.genHyperLinkToToC(obj.ChapterIndent);
        append(groupObj,linkPara);
        return;
    end


    resultType=sltest.testmanager.ReportUtility.getTypeOfTestResult(resultObj);
    testCaseType=sltest.testmanager.ReportUtility.getTestTypeOfResult(resultObj);

    mayHaveRunData=false;
    if(resultType==sltest.testmanager.TestResultTypes.TestIterationResult)
        mayHaveRunData=true;
    elseif(resultObj.NumTotalIterations==0)
        mayHaveRunData=true;
    end
    if(mayHaveRunData)
        if(testCaseType==sltest.testmanager.TestCaseTypes.Baseline||...
            testCaseType==sltest.testmanager.TestCaseTypes.Equivalence||...
            testCaseType==sltest.testmanager.TestCaseTypes.Scripted)

            comRun=resultObj.getComparisonRun();
            if(~isempty(comRun)&&~obj.ReportGenStatus<2)


                runBlock=obj.genRunBlockForTestCaseResult(comRun,...
                sltest.testmanager.RunTypes.Comparison,result,-1);
                if(~isempty(runBlock.Children))
                    append(groupObj,runBlock);
                end
            end


            if(testCaseType==sltest.testmanager.TestCaseTypes.Baseline)
                baselineRun=resultObj.getBaselineRun();
                if(~isempty(baselineRun))
                    runBlock=obj.genRunBlockForTestCaseResult(baselineRun,...
                    sltest.testmanager.RunTypes.Baseline,result,-1);
                    if(~isempty(runBlock.Children))
                        append(groupObj,runBlock);
                    end
                end
            end
        end

        verifyRun=resultObj.getVerifyRun();
        for i=1:numel(verifyRun)
            runBlock=obj.genRunBlockForTestCaseResult(verifyRun{i},...
            sltest.testmanager.RunTypes.VerifyResults,result,i);
            if(~isempty(runBlock.Children))
                append(groupObj,runBlock);
            end
        end


        assessmentResults=resultObj.getAssessmentResults();
        if~isempty(assessmentResults)
            for i=1:length(assessmentResults)
                assessmentResult=assessmentResults{i};
                if isempty(assessmentResult)
                    continue;
                end


                assessmentTitle=getString(message('sltest:assessments:editor:SectionTitle'));
                if length(assessmentResults)>1




                    isReleaseToBePrefixed=false;
                    currRel=getString(message('stm:MultipleReleaseTesting:CurrentRelease'));

                    rIds=stm.internal.getPermutationResultIDList(resultObj.getID());
                    releases=cell(length(rIds),1);
                    for j=1:length(rIds)

                        simResult=stm.internal.getPermutationResult(rIds(j));
                        rel=simResult.releaseName;
                        if isempty(rel)
                            rel=currRel;
                        elseif~strcmp(rel,currRel)
                            isReleaseToBePrefixed=true;
                        end
                        releases{j}=rel;
                    end
                    if isReleaseToBePrefixed
                        assessmentTitle=[releases{i},': ',assessmentTitle];%#ok<AGROW>
                    end
                    assessmentTitle=[assessmentTitle,' ',num2str(i)];%#ok<AGROW>
                end
                text=Text(assessmentTitle);
                sltest.testmanager.ReportUtility.setTextStyle(text,obj.BodyFontName,obj.BodyFontSize,obj.BodyFontColor,true,false);
                p=append(groupObj,Paragraph(text));

                p.Style={KeepWithNext(true),OuterMargin(obj.ChapterIndent,'0mm',obj.SectionSpacing,obj.SectionSpacing)};
                assessmentBlock=obj.genAssessmentsSummaryTable(assessmentResult);
                append(groupObj,assessmentBlock);
                append(groupObj,sltest.testmanager.ReportUtility.vspace(obj.SectionSpacing));
            end
        end


        nSimulations=1;
        if(testCaseType==sltest.testmanager.TestCaseTypes.Equivalence)
            nSimulations=2;
        end


        for simIdx=1:nSimulations
            runs=resultObj.getInputRuns(simIdx);
            if(isempty(runs))
                continue;
            end
            for runId=1:length(runs)
                runBlock=obj.genRunBlockForTestCaseResult(runs(runId),...
                sltest.testmanager.RunTypes.InputRun,result,simIdx);
                if(~isempty(runBlock.Children))
                    append(groupObj,runBlock);
                end
            end
        end



        for simIdx=1:nSimulations
            if(obj.ReportGenStatus>=2)
                break;
            end
            run=resultObj.getOutputRuns(simIdx);
            if isempty(run)
                run=struct('id',-1,'SignalCount',0);
            end

            runBlock=obj.genRunBlockForTestCaseResult(run,...
            sltest.testmanager.RunTypes.Simulation,result,simIdx);
            if(~isempty(runBlock.Children))
                append(groupObj,runBlock);
            end
        end
    end

    if(obj.IncludeErrorMessages)

        if(~isempty(resultObj.LogMessages.TestCase))
            tmpName=getString(message('stm:ReportContent:Field_TestLogs'));
            msgPart=sltest.testmanager.ReportUtility.genMessageBlock(obj,resultObj.LogMessages.TestCase,tmpName,'Black',obj.ChapterIndent);
            append(groupObj,msgPart);
        end
        if(~isempty(resultObj.ErrorMessages.TestCase))
            tmpName=getString(message('stm:ReportContent:Field_TestError'));
            msgPart=sltest.testmanager.ReportUtility.genMessageBlock(obj,resultObj.ErrorMessages.TestCase,tmpName,'Red',obj.ChapterIndent);
            append(groupObj,msgPart);
        end
        if(~isempty(resultObj.LogMessages.TestCase)||~isempty(resultObj.ErrorMessages.TestCase))
            linkPara=obj.genHyperLinkToToC(obj.ChapterIndent);
            append(groupObj,linkPara);
            append(groupObj,sltest.testmanager.ReportUtility.vspace(obj.SectionSpacing));
        end
    end


    customCriteriaPart=obj.genCustomCriteriaResultBlock(result.Data);
    if~isempty(customCriteriaPart)
        append(groupObj,customCriteriaPart);
    end


    if(obj.IncludeMATLABFigures)
        customCriteriaPlotsPart=obj.genCustomCriteriaPlotsBlock(result.Data);
        if~isempty(customCriteriaPlotsPart)
            append(groupObj,customCriteriaPlotsPart);
        end
    end
end
