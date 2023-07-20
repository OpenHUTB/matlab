function[agcvd,errmsg]=aggregateData(~,children,topModelName)






    try
        errmsg='';
        firstChildIdx=1;
        if numel(children)>1
            for idx=1:numel(children)
                d=children{idx}.data;
                cvd=d.getCvd();
                if isa(cvd,'cv.cvdatagroup')

                    break;
                end
                modelcovId=cv('get',cvd.rootId,'.modelcov');
                dataModelName=SlCov.CoverageAPI.getModelcovName(modelcovId);
                if strcmpi(topModelName,dataModelName)
                    firstChildIdx=idx;
                    break;
                end
            end
        end
        firstChild=children{firstChildIdx};
        firstData=firstChild.data;
        agcvd=firstData.getCvd();
        agcvd.description=firstData.description;
        ago=cv.aggregation;
        runInfo.runId=firstChildIdx;
        runInfo.runName=firstChild.getLabel;
        runInfo.testId=struct('uuid',{firstChild.getUUID},'contextType',{'RE'});
        agcvd.testRunInfo=runInfo;
        ago=addToAggregationObj(ago,agcvd);

        if numel(children)>1
            for idx=1:numel(children)
                if idx~=firstChildIdx
                    child=children{idx};
                    cvd=child.data.getCvd();

                    runInfo.runId=idx;
                    runInfo.runName=child.getLabel;
                    runInfo.testId=struct('uuid',{child.getUUID},'contextType',{'RE'});
                    cvd.testRunInfo=runInfo;

                    ago=addToAggregationObj(ago,cvd);
                end
            end
            agcvd=ago.getSumWithAddSubsys;
        end

    catch MEx
        errmsg=MEx.message;
        agcvd=[];

    end
end

function ago=addToAggregationObj(ago,cvd)
    assoc='';
    if isa(cvd,'cvdata')
        mi=cvd.modelinfo;

        if~isempty(mi.ownerBlock)&&contains(mi.analyzedModel,'/')
            assoc=mi.ownerBlock;
        end
    end
    ago.addData(cvd,assoc);
end
