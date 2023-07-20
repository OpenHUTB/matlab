function result=getLoggedSignalsFromMappingInfo(assessmentsInfo,simulationIndex,modelToRun)


    result=[];
    if nargin<2
        simulationIndex=1;
        modelToRun='';
    end

    evaluator=sltest.assessments.internal.AssessmentsEvaluator(assessmentsInfo);
    if~evaluator.hasAssessments()
        return;
    end

    [symbolsInfo1,~]=evaluator.parseSymbols({'Signal'},1,modelToRun);

    if simulationIndex==1

        symbolsInfo=symbolsInfo1;
    else

        [symbolsInfo,~]=evaluator.parseSymbols({'Signal'},2,modelToRun,symbolsInfo1);
    end

    symbols=fields(symbolsInfo);
    for i=1:length(symbols)
        result=[result,getLoggedSignal(symbolsInfo.(symbols{i}))];%#ok<AGROW>
    end
end

function result=getLoggedSignal(symbolInfo)
    result.Name=symbolInfo.value;
    result.Checked=true;
    bindableMetaData=symbolInfo.children.bindableMetaData.value;
    result.BlockPath=bindableMetaData.blockPathStr;
    result.HierarchicalPath=symbolInfo.children.Path.value;
    result.ElementType=0;
    result.SDIBlockPath=string;



    basePath=bindableMetaData.hierarchicalPathArr{2};
    tmp=strfind(basePath,'/');
    baseModel=basePath(1:tmp(1)-1);
    result.TopModel=baseModel;

    result.SID='';
    result.PortIndex=symbolInfo.children.PortIndex.value;
    result.id=-1;
    result.PlotIndices='';
end


