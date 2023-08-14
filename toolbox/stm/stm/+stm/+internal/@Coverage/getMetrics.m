



function coverageResults=getMetrics(covObjects,ownerType,ownerFullPath,varargin)
    import stm.internal.Coverage;

    file_name='';
    if nargin==4
        file_name=varargin{1};
    end

    coverageResults=struct(...
    'filename','',...
    'aggregatedCvdataIds','',...
    'topLevelModel','',...
    'analyzedModel','',...
    'metricSettings','',...
    'metrics',getMetricsStruct,...
    'checksum',num2cell(arrayfun(@(cvobj)cvobj.checksum,covObjects)).',...
    'structuralChecksum',num2cell(arrayfun(@(cvobj)cvobj.structuralChecksum,covObjects)).',...
    'relBndMetricChecksum',num2cell(arrayfun(@(cvobj)cvobj.relBndMetricChecksum,covObjects)).',...
    'satOvfMetricChecksum',num2cell(arrayfun(@(cvobj)cvobj.satOvfMetricChecksum,covObjects)).',...
    'ownerType','',...
    'ownerFullPath','',...
    'Status','',...
    'cloneId',0,...
    'SimMode','',...
    'Release','',...
    'FilterFile',string.empty);

    for x=1:numel(covObjects)
        cvdataObj=covObjects(x);

        if isempty(file_name)
            filename=Coverage.saveToFile(cvdataObj);
        else
            filename=[tempname,'.cvt'];
            [status,msg,msgid]=movefile(file_name,filename,'f');
        end
        coverageResults(x).filename=filename;

        aggregatedCvdataIds=cvdataObj.aggregatedIds;
        if~isempty(aggregatedCvdataIds)
            aggregatedCvdataIds=join(aggregatedCvdataIds);
            coverageResults(x).aggregatedCvdataIds=aggregatedCvdataIds{1};
        end

        analyzedModel=Coverage.getAnalyzedModel(cvdataObj,ownerType,ownerFullPath);
        coverageResults(x).analyzedModel=analyzedModel;

        [slvnvAnalyzedModel,isHarnessOpen]=Coverage.getSlvnvAnalyzedModel(...
        cvdataObj,analyzedModel,ownerType,ownerFullPath);
        ownerModel=Coverage.getOwnerModel(cvdataObj.modelinfo);
        ownerModel=ownerModel{1};
        if~isHarnessOpen&&Coverage.isModel(ownerModel)&&Coverage.isLibrary(ownerModel)
            oc=Coverage.restoreLibraryLock(ownerModel);%#ok<NASGU>
        end



        contextGuard=SlCov.ContextGuard.createAtomicCovQueryGuard(cvdataObj);

        coverageResults(x).metrics.decisioninfo=getMetric(cvdataObj,slvnvAnalyzedModel,'decision');
        coverageResults(x).metrics.conditioninfo=getMetric(cvdataObj,slvnvAnalyzedModel,'condition');
        coverageResults(x).metrics.mcdcinfo=getMetric(cvdataObj,slvnvAnalyzedModel,'mcdc');
        coverageResults(x).metrics.tableinfo=getMetric(cvdataObj,slvnvAnalyzedModel,'tableExec');
        coverageResults(x).metrics.executioninfo=getMetric(cvdataObj,slvnvAnalyzedModel,cvmetric.Structural.block);
        coverageResults(x).metrics.relationalboundaryinfo=getMetric(cvdataObj,slvnvAnalyzedModel,cvmetric.Structural.relationalop);
        coverageResults(x).metrics.overflowsaturationinfo=getMetric(cvdataObj,slvnvAnalyzedModel,cvmetric.Structural.saturate);
        coverageResults(x).metrics.sldvtest=getMetric(cvdataObj,slvnvAnalyzedModel,cvmetric.Sldv.test);
        coverageResults(x).metrics.sldvproof=getMetric(cvdataObj,slvnvAnalyzedModel,cvmetric.Sldv.proof);
        coverageResults(x).metrics.sldvcondition=getMetric(cvdataObj,slvnvAnalyzedModel,cvmetric.Sldv.condition);
        coverageResults(x).metrics.sldvassumption=getMetric(cvdataObj,slvnvAnalyzedModel,cvmetric.Sldv.assumption);


        coverageResults(x).metrics.complexityinfo=complexityinfo(cvdataObj,slvnvAnalyzedModel);


        coverageResults(x).metricSettings=structfun(@logical,cvdataObj.testSettings,'uniformoutput',false);


        [~,desc]=executioninfo(cvdataObj,slvnvAnalyzedModel);
        if isfield(desc,'function')
            covFcns=desc.function(~[desc.function.isFiltered]);
            covFcnsJustified=[covFcns.justifiedCoverage]>0;
            numHit=nnz([covFcns(~covFcnsJustified).executionCount]>0);
            numJustified=nnz(covFcnsJustified);
            coverageResults(x).metrics.functioninfo=[numHit+numJustified,numel(covFcns),numJustified];
        end

        if isfield(desc,'functionCall')
            covFcnCalls=desc.functionCall(~[desc.functionCall.isFiltered]);
            covFcnCallsJustified=[covFcnCalls.justifiedCoverage]>0;
            numHit=nnz([covFcnCalls(~covFcnCallsJustified).executionCount]>0);
            numJustified=nnz(covFcnCallsJustified);
            coverageResults(x).metrics.functioncallinfo=[numHit+numJustified,numel(covFcnCalls),numJustified];
        end

        coverageResults(x).ownerType=ownerType;
        coverageResults(x).ownerFullPath=ownerFullPath;

        coverageResults(x).Status=Coverage.getStatus(cvdataObj.modelinfo.analyzedModel);

        coverageResults(x).SimMode=char(cvdataObj.simMode);
        coverageResults(x).Release=regexprep(cvdataObj.dbVersion,'[() ]','');

        if~isempty(cvdataObj.filter)
            coverageResults(x).FilterFile=string(cvdataObj.filter);
        end
        delete(contextGuard);
    end
end

function strct=getMetricsStruct
    strct=struct('decisioninfo',[],...
    'mcdcinfo',[],...
    'relationalboundaryinfo',[],...
    'conditioninfo',[],...
    'tableinfo',[],...
    'overflowsaturationinfo',[],...
    'executioninfo',[],...
    'sldvtest',[],...
    'sldvproof',[],...
    'sldvcondition',[],...
    'sldvassumption',[],...
    'complexityinfo',[],...
    'functioninfo',[],...
    'functioncallinfo',[]);
end

function metric=getMetric(cvd,model,metricName)
    [numSatisfied,numJustified,numTotal]=SlCov.CoverageAPI.getHitCount(cvd,model,metricName);
    if(numTotal==0)
        metric=[];
    else
        metric=[numSatisfied+numJustified,numTotal,numJustified];
    end
end
