function metricIndexMap=getMetricIndices(data,allCvIds,allMetricNames)





    try

        cvi.ReportData.updateDataIdx(data);
        metricIndexMap=struct('cvId',{allCvIds},'metricIndex',[]);


        for idx=1:numel(allCvIds)

            blockCvId=allCvIds(idx);
            ind=[];
            for ii=1:numel(allMetricNames)

                metricEnum=cvi.MetricRegistry.getEnum(allMetricNames{ii});


                idxStruct=getTotalIdx(blockCvId,metricEnum);

                baseObj=cv('MetricGet',blockCvId,metricEnum,'.baseObj');
                for iii=1:numel(baseObj)
                    bo=baseObj(iii);
                    isa=cv('get',bo,'.isa');
                    if isa==cv('get','default','decision.isa')
                        tIdxStruct=getDecisionIdx(bo);
                    elseif isa==cv('get','default','condition.isa')
                        tIdxStruct=getConditionIdx(bo);
                    elseif isa==cv('get','default','mcdc.isa')
                        tIdxStruct=getMcdcIdx(bo);
                    elseif isa==cv('get','default','table.isa')
                        tIdxStruct=getTableIdx(bo);

                    end
                    if~isempty(idxStruct)
                        if isfield(tIdxStruct,'metadata')&&~isfield(idxStruct,'metadata')
                            idxStruct.metadata=[];
                        end
                        idxStruct=[idxStruct,tIdxStruct];
                    else
                        idxStruct=tIdxStruct;
                    end
                end
                ind.(allMetricNames{ii})=idxStruct;
            end

            metricIndexMap(idx).metricIndex=ind;
        end
    catch MEx
        rethrow(MEx);
    end
end

function idxStruct=getTotalIdx(blockCvId,metricEnum)
    idxStruct=[];
    totalIdx=cv('MetricGet',blockCvId,metricEnum,'.dataIdx.deep');
    if~isempty(totalIdx)
        idxStruct.idx=totalIdx+1;
        idxStruct.size=1;
    end
end

function idxStruct=getDecisionIdx(decisionId)

    [idx,size,hasVariableSize,activeOutcomeIdx]=cv('get',decisionId,'.dc.baseIdx','.dc.numOutcomes','.hasVariableSize','.dc.activeOutcomeIdx');
    idxStruct=struct('idx',{idx+1},'size',{size});
    if hasVariableSize
        idxStruct(3)=struct('idx',{activeOutcomeIdx+1},'size',{1});
    end

end


function idxStruct=getConditionIdx(conditionId)
    [falseCountIdx,trueCountIdx,hasVariableSize,activeCondIdx]=cv('get',conditionId,'.coverage.falseCountIdx','.coverage.trueCountIdx','.hasVariableSize','.coverage.activeCondIdx');
    idxStruct=struct('idx',{falseCountIdx+1,trueCountIdx+1},'size',{1,1});
    if hasVariableSize
        idxStruct(3)=struct('idx',{activeCondIdx+1},'size',{1});
    end
end

function idxStruct=getTableIdx(tableId)

    [numDimensions,dimBrkSizes,brkPtEquality,intervalExec]=cv('get',tableId,'.numDimensions','.dimBrkSizes','.dataBaseIdx.brkPtEquality','.dataBaseIdx.intervalExec');
    brkPtTotal=0;
    intervalTotal=1;
    for idx=1:numDimensions
        brkPtTotal=brkPtTotal+dimBrkSizes(idx)+1;
        intervalTotal=intervalTotal*(dimBrkSizes(idx)+1);
    end

    idxStruct=struct('idx',{brkPtEquality+1,intervalExec+1},'size',{brkPtTotal,intervalTotal});

end


function idxStruct=getMcdcIdx(mcdcId)

    [predSatisfied,trueTableEntry,falseTableEntry,pathHitBits,pathOutBits,...
    numPredicate,shortCircuiting,exprType,pathStorageCount,...
    hasVariableSize,activeCondIdx,mcdcMode,isCascMCDC]...
    =cv('get',mcdcId,'.dataBaseIdx.predSatisfied',...
    '.dataBaseIdx.trueTableEntry',...
    '.dataBaseIdx.falseTableEntry',...
    '.dataBaseIdx.pathHitBits',...
    '.dataBaseIdx.pathOutBits',...
    '.numPredicate',...
    '.shortCircuiting',...
    '.exprType',...
    '.pathStorageCount',...
    '.hasVariableSize',...
    '.dataBaseIdx.activeCondIdx',...
    '.mcdcMode',...
    '.cascMCDC.isCascMCDC');

    if mcdcMode==0
        metaData_T=[];
        metaData_F=[];
        metaData_PredSat=[];
    else
        metaData_T=struct('tableEntryType',{SlCov.PredSatisfied.True_Only},'predSatisfiedIdx',{predSatisfied+1});
        metaData_F=struct('tableEntryType',{SlCov.PredSatisfied.False_Only},'predSatisfiedIdx',{predSatisfied+1});
        metaData_PredSat=struct('needsTrace',true);
    end

    idxStruct=struct('idx',{trueTableEntry+1,falseTableEntry+1,predSatisfied+1,pathHitBits+1},...
    'size',{numPredicate,numPredicate,numPredicate,pathStorageCount},...
    'metadata',{metaData_T,metaData_F,metaData_PredSat,[]});

    if hasVariableSize
        idxStruct(end+1)=struct('idx',{activeCondIdx+1},'size',{1},'metadata',{[]});
    end

    if(exprType==6)||...
        (exprType==7)||...
        (exprType==0&&shortCircuiting==1&&~isCascMCDC)

        idxStruct(end+1)=struct('idx',{pathOutBits+1},'size',{pathStorageCount},'metadata',{[]});
    end
end