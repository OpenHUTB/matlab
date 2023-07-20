function logAnalysisResults(~,sldvData)




    if~(slavteng('feature','LogSLDVDDUX'))

        return;
    end


    dataToLog=prepareDDUXData(sldvData);

    if~isempty(dataToLog)
        eventKey="DV_ANALYSIS_RESULTS";


        sldv.ddux.Logger.getInstance().logData(eventKey,dataToLog);
    end

end

function dataToLog=prepareDDUXData(sldvData)
    try
        dataToLog=struct();


        dataToLog.maxProcessTime=sldvData.AnalysisInformation.Options.MaxProcessTime;
        dataToLog.actualTime=sldvData.AnalysisInformation.ElapsedTime;
        dataToLog.lastObjectiveDecidedTime=getLastObjectiveDecidedTime(sldvData.Objectives);


        objectiveInfo=getDDUXObjectiveInfo(sldvData.Objectives);
        fields=fieldnames(objectiveInfo);
        for i=1:numel(fields)
            dataToLog.(fields{i})=objectiveInfo.(fields{i});
        end


        approximationFlags=sldvData.AnalysisInformation.Approximations.flags;
        dataToLog.lutApproximations=sldvprivate('bool2double',approximationFlags.lookupApproxisReported);
        dataToLog.rationalApproximations=sldvprivate('bool2double',approximationFlags.hasDouble2RatConvert);
        dataToLog.whileApproximations=sldvprivate('bool2double',approximationFlags.hasWhileLoopApprox);

        return;
    catch MEx %#ok<NASGU>
        dataToLog=[];
    end
end

function lastObjTime=getLastObjectiveDecidedTime(objectives)
    lastObjTime=0;

    objAnalysisTimes=[objectives.analysisTime];
    objAnalysisTimes=objAnalysisTimes(objAnalysisTimes>0);
    if~isempty(objAnalysisTimes)
        lastObjTime=max(objAnalysisTimes);
    end
end

function objectiveInfo=getDDUXObjectiveInfo(objectives)
    objectiveInfo=struct('totalObjectives',0,'numDECObjectives',0,...
    'numNTCObjectives',0,'numBOUObjectives',0,...
    'numSIMObjectives',0,'numUSATObjectives',0,...
    'numAPXObjectives',0,'numNLRObjectives',0,...
    'numSTUBObjectives',0,'numRTEObjectives',0,...
    'numUDECObjectives',0);

    objCount=0;
    numObjectives=numel(objectives);
    for objIdx=1:numObjectives
        [bucket,isValidGoal]=sldvprivate('getDDUXObjectiveBucket',objectives(objIdx).status,...
        objectives(objIdx).type);
        if~isempty(bucket)
            bucketField=['num',bucket,'Objectives'];
            objectiveInfo.(bucketField)=objectiveInfo.(bucketField)+1;
        end
        if isValidGoal
            objCount=objCount+1;
        end
    end

    objectiveInfo.('totalObjectives')=objCount;
end


