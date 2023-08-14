function analysisInfo=getDefaultAnalysisInfo(modelH)




    analysisInfo.designModelH=modelH;
    analysisInfo.extractedModelH=modelH;
    analysisInfo.analyzedModelH=modelH;
    analysisInfo.analyzedSubsystemH=[];
    analysisInfo.analyzedAtomicSubchartWithParam=false;
    analysisInfo.blockDiagramExtract=false;
    analysisInfo.exportFcnGroupsInfo=[];
    analysisInfo.stubbedSimulinkFcnInfo=[];
    analysisInfo.strictBusErros=false;
    analysisInfo.replacementInfo.replacementsApplied=false;
    analysisInfo.replacementInfo.tempReplacement=true;
    analysisInfo.replacementInfo.replacementModelH=[];
    analysisInfo.replacementInfo.replacementTable=[];
    analysisInfo.replacementInfo.notReplacedBlksTable=[];
    analysisInfo.replacementInfo.mdlsLoadedForMdlRefTree={};
    analysisInfo.mappedSfId=[];
    analysisInfo.mappedBlockH=[];
    analysisInfo.testMode=logical(slavteng('feature','TestMode'));
    analysisInfo.disabledCvIdInfo=[];
    analysisInfo.linkStorage=[];
    analysisInfo.paramsSampleTimes=[];
    analysisInfo.paramsRunTimeTypes=[];
    analysisInfo.appliedTimerOptimizations={};
    analysisInfo.unsafeCastForTestGen={};
    analysisInfo.hasNotInterpretableStubbedElem=false;
    analysisInfo.actualCommandForAnalysis='';
    analysisInfo.erroredObjectivesInfo=[];
    analysisInfo.useTranslationCache=false;
    analysisInfo.fixptRangeAnalysisMode=false;
    if ishandle(modelH)
        valueInRangeAnalysisMode=get_param(modelH,'InRangeAnalysisMode');
        if strcmpi(valueInRangeAnalysisMode,'on')
            analysisInfo.fixptRangeAnalysisMode=true;
        end
    end

end

