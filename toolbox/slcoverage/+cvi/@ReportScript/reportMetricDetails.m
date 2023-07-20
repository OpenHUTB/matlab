function reportMetricDetails(this,blkEntry,inReport,options)



    code=cv('get',blkEntry.cvId,'.code');

    if code~=0
        emlBlkEntry=blkEntry;

        if isfield(emlBlkEntry,'decision')&&~isempty(emlBlkEntry.decision)
            numOfDecs=cv('get',code,'.totalNumOfObjs.numOfDecs');
            totalNumOfDecs=numel(emlBlkEntry.decision.decisionIdx);

            if numOfDecs~=totalNumOfDecs
                emlBlkEntry.decision.decisionIdx=blkEntry.decision.decisionIdx(totalNumOfDecs-numOfDecs+1:end);
                blkEntry.decision.decisionIdx=blkEntry.decision.decisionIdx(1:totalNumOfDecs-numOfDecs);
                decision_details(this,blkEntry,this.cvstruct,options);
            end
        end
        dump_eml(this,emlBlkEntry,inReport,options);
    else

        if this.hasDecisionInfo
            decision_details(this,blkEntry,this.cvstruct,options);
        end

        if this.hasConditionInfo
            condition_details(this,blkEntry,this.cvstruct,options);
        end

        if this.hasTableExecInfo
            tableExec_details(this,blkEntry,this.cvstruct,options);
        end

        if this.hasMcdcInfo
            mcdc_details(this,blkEntry,this.cvstruct,options);
        end

        if this.hasTestobjectiveInfo
            for mIdx=1:numel(this.toMetricNames)
                metricName=this.toMetricNames{mIdx};
                testobjective_details(this,blkEntry,this.cvstruct,metricName,options);
            end
        end

    end
