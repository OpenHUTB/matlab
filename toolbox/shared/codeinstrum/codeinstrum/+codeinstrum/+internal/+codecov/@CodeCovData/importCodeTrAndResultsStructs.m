



function importCodeTrAndResultsStructs(obj,loadedObj)

    dbFilePath=tempname;


    internal.cxxfe.instrum.TraceabilityData.importTraceabilityStruct(dbFilePath,loadedObj.CodeTrRef.value);

    codeTr=codeinstrum.internal.TraceabilityData(dbFilePath);


    metricNames=fieldnames(loadedObj.Results.config.metrics);
    metricsIdx=cellfun(@(fld)loadedObj.Results.config.metrics.(fld),metricNames);
    metricNames(~metricsIdx)=[];

    moduleName=regexprep(loadedObj.CodeTrKey,'(.*)-.*','$1');
    isInstanceBased=loadedObj.Results.config.isInstanceBased;

    if isfield(loadedObj.Results.config,'mcdcMode')
        mcdcMode=loadedObj.Results.config.mcdcMode;
    else
        mcdcMode='UniqueCause';
    end


    if isempty(loadedObj.Results.mcdc.numCombinationsHits)
        numMcdcResults=0;
    else
        numMcdcResults=size(loadedObj.Results.mcdc.numCombinationsHits{1},2);
    end

    if isfield(loadedObj.Results,'funCalls')
        numFunCallsResults=size(loadedObj.Results.funCalls.numHits,2);
    else
        numFunCallsResults=0;
    end
    if isfield(loadedObj.Results,'relationalOps')
        numRelOpsResults=size(loadedObj.Results.relationalOps.numWithinTolLessHits,2);
    else
        numRelOpsResults=0;
    end
    numResults=max([size(loadedObj.Results.decOutcomes.numHits,2)...
    ,size(loadedObj.Results.conditions.numTrueHits,2)...
    ,size(loadedObj.Results.statements.numHits,2)...
    ,size(loadedObj.Results.exitPoints.numHits,2)...
    ,numFunCallsResults...
    ,numRelOpsResults...
    ,size(loadedObj.Results.functions.numHits,2)...
    ,numMcdcResults],[],'all');
    if isInstanceBased&&(numResults>1)
        numResults=numResults-1;
    end

    instDbFilePaths=cell(1,numResults);

    for resIdx=1:numResults

        instDbFilePath=tempname;
        instDbFilePaths{resIdx}=instDbFilePath;
        covRslt=internal.cxxfe.instrum.runtime.ResultHitsManager.startRecord(dbFilePath,instDbFilePath,'',struct());



        if isempty(loadedObj.Results.decOutcomes.numHits)
            numDecOutcomeHits=zeros(0,2,'int64');
        else
            numDecOutcomeHits=cat(2,loadedObj.CodeTrRef.value.decOutcomes.covId(loadedObj.Results.decOutcomes.idx,:),...
            loadedObj.Results.decOutcomes.numHits(:,resIdx));
        end

        if isempty(loadedObj.Results.conditions.numTrueHits)
            numConditionsHits=zeros(0,2,'int64');
        else
            numConditionsHits=cat(1,cat(2,loadedObj.CodeTrRef.value.conditions.covId(loadedObj.Results.conditions.idx,:),...
            loadedObj.Results.conditions.numTrueHits(:,resIdx)),...
            cat(2,loadedObj.CodeTrRef.value.conditions.covId(loadedObj.Results.conditions.idx,:)+int64(1),...
            loadedObj.Results.conditions.numFalseHits(:,resIdx)));
        end

        if isempty(loadedObj.Results.statements.numHits)
            numStatementsHits=zeros(0,2,'int64');
        else
            numStatementsHits=cat(2,loadedObj.CodeTrRef.value.statements.covId(loadedObj.Results.statements.idx,:),...
            loadedObj.Results.statements.numHits(:,resIdx));
        end

        if isempty(loadedObj.Results.exitPoints.numHits)
            numExitPointsHits=zeros(0,2,'int64');
        else
            numExitPointsHits=cat(2,loadedObj.CodeTrRef.value.exitPoints.covId(loadedObj.Results.exitPoints.idx,:),...
            loadedObj.Results.exitPoints.numHits(:,resIdx));
        end

        if numFunCallsResults==0
            numFunCallsHits=zeros(0,2,'int64');
        else
            numFunCallsHits=cat(2,loadedObj.CodeTrRef.value.funCalls.covId(loadedObj.Results.funCalls.idx,:),...
            loadedObj.Results.funCalls.numHits(:,resIdx));
        end

        if numRelOpsResults==0
            numRelationalOpsHits=zeros(0,2,'int64');
        else
            intRelIdx=(loadedObj.Results.relationalOps.numEqHits(:,resIdx)>=0);
            ofst=int64(intRelIdx);
            numEqHits=cat(2,loadedObj.CodeTrRef.value.relationalOps.covId(loadedObj.Results.relationalOps.idx,:)+int64(1),...
            loadedObj.Results.relationalOps.numEqHits(:,resIdx));
            numEqHits(~intRelIdx,:)=[];
            numRelationalOpsHits=cat(1,cat(2,loadedObj.CodeTrRef.value.relationalOps.covId(loadedObj.Results.relationalOps.idx,:),...
            loadedObj.Results.relationalOps.numWithinTolLessHits(:,resIdx)),...
            numEqHits,...
            cat(2,loadedObj.CodeTrRef.value.relationalOps.covId(loadedObj.Results.relationalOps.idx,:)+int64(1)+ofst,...
            loadedObj.Results.relationalOps.numWithinTolGreaterHits(:,resIdx)));
        end

        if isempty(loadedObj.Results.functions.numHits)
            numFunctionsHits=zeros(0,2,'int64');
        else
            numFunctionsHits=cat(2,loadedObj.CodeTrRef.value.functions.covId(loadedObj.Results.functions.idx,:),...
            loadedObj.Results.functions.numHits(:,resIdx));
        end
        numHits=cat(1,numDecOutcomeHits,numConditionsHits,numStatementsHits,numExitPointsHits,numFunCallsHits,...
        numRelationalOpsHits,numFunctionsHits);

        [~,idx]=unique(numHits(:,1));
        numHits=numHits(idx,:);


        for ii=1:numel(loadedObj.Results.mcdc.numCombinationsHits)
            decCovId=loadedObj.CodeTrRef.value.mcdc.covId(loadedObj.Results.mcdc.idx(ii));
            instrPt=codeTr.getInstrumentationPoint(decCovId);
            decCovPt=instrPt.Container;
            mcdcCovPt=decCovPt.mcdc;
            mcdcCovId=mcdcCovPt.covId;
            numCombinationsHits=loadedObj.Results.mcdc.numCombinationsHits{ii};
            numCombinations=size(numCombinationsHits,1);
            hitsMcdc=[int64(mcdcCovId)+int64(0:numCombinations-1)',numCombinationsHits(:,resIdx)];
            numHits=cat(1,numHits,hitsMcdc);
        end
        globalHits=accumarray(numHits(:,1),numHits(:,2));
        globalHits=uint32(globalHits);
        covRslt.receiveHitsTable(-1,globalHits);
        internal.cxxfe.instrum.runtime.ResultHitsManager.stopRecord(instDbFilePath,'');


        covRslt=internal.cxxfe.instrum.runtime.ResultHitsManager.import(instDbFilePath);
        extraData.startTime=datestr(datetime(loadedObj.Results.config.run.startTime,'InputFormat','dd-MMM-yyyy HH:mm:ss','Locale','en_US'),'yyyy-mm-dd HH:MM:ss');
        extraData.endTime=datestr(datetime(loadedObj.Results.config.run.endTime,'InputFormat','dd-MMM-yyyy HH:mm:ss','Locale','en_US'),'yyyy-mm-dd HH:MM:ss');
        covRslt.setExtraDatas(extraData);
        covRslt.writeToFile(covRslt.Path);
        internal.cxxfe.instrum.runtime.ResultHitsManager.clear(instDbFilePath);
    end



    if strcmp(loadedObj.SourceKind,'Generated Code')
        codeTr.SourceKind=internal.cxxfe.instrum.SourceKind.ECoder;
    else
        codeTr.SourceKind=loadedObj.SourceKind;
    end
    codeTr.close();
    delete(dbFilePath);

    obj.CodeCovDataImpl=internal.codecov.CodeCovData(codeTr);
    obj.Name=loadedObj.Name;
    obj.CodeCovDataImpl.setMetrics(metricNames);
    obj.McdcMode=mcdcMode;
    obj.CodeCovDataImpl.setResults(instDbFilePaths,isInstanceBased,false);
    cellfun(@delete,instDbFilePaths);
    if isInstanceBased
        for ii=1:numel(loadedObj.Instances)
            res=obj.getInstanceResults(ii);
            if isfield(loadedObj.Instances,'SID')
                sid=loadedObj.Instances(ii).SID;
            else
                sid='';
            end
            res.createIntoInstance(struct('metaClass','internal.codecov.InstanceInfo',...
            'sid',sid,...
            'name',loadedObj.Instances(ii).name));
        end
    end


