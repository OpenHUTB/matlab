function suppressCodeExecutionProfiling=checkProfilingConfigForComponent...
    (lCodeExecutionProfilingTop,lCodeStackProfilingTop,lCodeProfilingWCETAnalysis,...
    thisModel,lTopOfBuildModel,...
    lTopModelStandalone,lExecTimeCallbackPrm,lXilInfo,...
    lSystemTargetFile,lCodeCoverageSpec,lIsExtModeXCP)





    lTargetOptedInToProfiling=~strcmp...
    (lExecTimeCallbackPrm,'coder.internal.profilingEmptyTimerCallback');

    lActiveCoverage=false;
    isSLCoverage=false;

    if~isempty(lCodeCoverageSpec)
        ccs=lCodeCoverageSpec.CodeCovSettingsSL;
        topModelCoverage=strcmp(ccs.TopModelCoverage,'on')&&...
        strcmp(thisModel,lTopOfBuildModel);
        refModelCoverage=strcmp(ccs.ReferencedModelCoverage,'on')&&...
        ~strcmp(thisModel,lTopOfBuildModel);
        lActiveCoverage=topModelCoverage||refModelCoverage;
        isSLCoverage=coder.internal.isSLCovInstalled()&&...
        strcmp(ccs.CoverageTool,SlCov.getCoverageToolName());
    end

    if lCodeProfilingWCETAnalysis
        i_checkWCETProfiling(lXilInfo,lTopOfBuildModel,thisModel,lActiveCoverage,lTopModelStandalone);
        suppressCodeExecutionProfiling=true;
        return
    elseif lCodeStackProfilingTop




        i_checkStackProfiling(lXilInfo,lTopOfBuildModel,thisModel,...
        lActiveCoverage,lTopModelStandalone);
        suppressCodeExecutionProfiling=true;
        return
    elseif~lCodeExecutionProfilingTop


        suppressCodeExecutionProfiling=true;
        return
    else
        suppressCodeExecutionProfiling=false;
    end

    if lActiveCoverage&&lCodeExecutionProfilingTop
        i_reportCoverageAndProfilingConflict(lTopOfBuildModel,thisModel,isSLCoverage);
    end

    nonSilPilCodeProfilingSTFs={...
    'slrt.tlc',...
    'slrtert.tlc',...
    'grt_profiling_test.tlc',...
    'xpctarget.tlc',...
    'xpctargetert.tlc'};
    modelProfilingSupported=lXilInfo.ModelProfilingAllowed...
    ||lTargetOptedInToProfiling;
    if lCodeExecutionProfilingTop&&lIsExtModeXCP


        return;
    elseif slfeature('xPCFunctionProfiling')==0&&...
        any(strcmp(nonSilPilCodeProfilingSTFs,lSystemTargetFile))
        DAStudio.error('CoderProfile:ExecutionTime:xPCFunctionProfilingCtrlB');
    elseif lTopModelStandalone&&~modelProfilingSupported
        MSLDiagnostic('CoderProfile:ExecutionTime:ExecutionProfilingCtrlB').reportAsWarning;
    end


    function i_reportCoverageAndProfilingConflict(lTopOfBuildModel,model,isSLCoverage)

        profInstrDialogStr=DAStudio.message('RTW:configSet:ERTDialogCodeProfInstr');
        if isSLCoverage
            DAStudio.error('CoderProfile:ExecutionTime:SLCodeCoverageEnabled',...
            model,lTopOfBuildModel,profInstrDialogStr,model);
        else
            DAStudio.error('CoderProfile:ExecutionTime:CodeCoverageEnabled',...
            model,lTopOfBuildModel,profInstrDialogStr,model);
        end


        function i_checkStackProfiling(lXilInfo,lTopOfBuildModel,model,lActiveCoverage,lTopModelStandalone)
            stackProfilingTxt='Measure task stack usage';
            if lXilInfo.IsPil&&~coder.profile.private.featureOn('PILStack')
                DAStudio.error('CoderProfile:ExecutionStack:ProfilingNotSIL',stackProfilingTxt);
            end
            if lXilInfo.IsXilBlock
                DAStudio.error('CoderProfile:ExecutionStack:ProfilingXILBlock',stackProfilingTxt);
            end
            if lActiveCoverage
                DAStudio.error('CoderProfile:ExecutionStack:ProfilingAndCoverage',...
                model,lTopOfBuildModel,...
                stackProfilingTxt,model);
            end
            if lTopModelStandalone&&~lXilInfo.ModelProfilingAllowed
                DAStudio.error('CoderProfile:ExecutionStack:ProfilingCtrlB',...
                lTopOfBuildModel);
            end

            function i_checkWCETProfiling(lXilInfo,lTopOfBuildModel,model,lActiveCoverage,lTopModelStandalone)
                if lXilInfo.IsXilBlock
                    DAStudio.error('CoderProfile:ExecutionTime:WCETXILBlock');
                end
                if lActiveCoverage
                    DAStudio.error('CoderProfile:ExecutionTime:WCETAndCoverage',...
                    model,lTopOfBuildModel);
                end
                if lTopModelStandalone&&~lXilInfo.ModelProfilingAllowed
                    DAStudio.error('CoderProfile:ExecutionTime:WCETCtrlB',...
                    lTopOfBuildModel);
                end
