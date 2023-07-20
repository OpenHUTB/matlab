function decisions=getDecisionInfo(this,metricName,decisionData,decisionIds,txtDetail)






    for i=1:length(decisionIds)
        decId=decisionIds(i);
        decData=[];
        decData.cvId=decId;
        decData.metricName=metricName;
        decData.text=cvi.ReportUtils.getTextOf(decId,-1,[],txtDetail);
        [outcomes,startIdx,activeOutcomeIdx,hasVariableSize,collapseVector]=cv('get',decId,'.dc.numOutcomes','.dc.baseIdx','.dc.activeOutcomeIdx','.hasVariableSize','.collapseVector');
        [decData.startChar,decData.length]=cv('get',cv('get',decId,'.descriptor'),'.startChar','.length');
        slsfObjId=cv('get',decId,'.slsfobj');
        decData.isJustifiedByParent=cv('get',slsfObjId,'.isJustified');
        decData.isFilteredByParent=cv('get',slsfObjId,'.isDisabled');
        decData.linkStr='';

        if decData.isJustifiedByParent||decData.isFilteredByParent
            decData.filterRationale=cvi.ReportUtils.getFilterRationale(slsfObjId);
        else
            decData.filterRationale=cvi.ReportUtils.getFilterRationale(decId);
        end
        decData.isJustified=decData.isJustifiedByParent||cv('get',decId,'.isJustified');
        decData.isFiltered=decData.isFilteredByParent||cv('get',decId,'.isDisabled');

        decData.numOutcomes=outcomes;
        if outcomes==1
            decData.totals=decisionData(startIdx+1,:);
        else
            decData.totals=sum(decisionData((startIdx+1):(startIdx+outcomes),:));
        end
        if outcomes==1
            decData.outCnts=decisionData((startIdx+1):(startIdx+outcomes),:)>0;
        else
            decData.outCnts=sum(decisionData((startIdx+1):(startIdx+outcomes),:)>0);
        end

        decData.collapseVector=collapseVector;

        decData.isVariable=hasVariableSize;
        if(hasVariableSize)
            decData.hasVariableOutcome=true;
            decData.maxActOutcome=decisionData(activeOutcomeIdx+1,end);
            decData.isActive=any(decData.maxActOutcome>0);
            decData.covered=(decData.outCnts(end)==decData.maxActOutcome);
        else
            nel=numel(decData.outCnts);
            decData.hasVariableOutcome=false;
            decData.maxActOutcome=zeros(1,nel);
            decData.isActive=~cv('get',decId,'.isDisabled');
            decData.covered=(decData.outCnts(end)==outcomes);
        end

        maxActOutcome=max(decData.maxActOutcome);
        anyOutcomeJustified=false;
        justifiedCnts=0;
        filteredOutcomes=cv('get',decId,'.filteredOutcomes');
        filteredOutcomeModes=cv('get',decId,'.filteredOutcomeModes');

        for j=1:outcomes
            if~hasVariableSize||(hasVariableSize&&decData.isActive&&j<=maxActOutcome)
                decData.outcome(j).isActive=true;
                decData.outcome(j).execCount=decisionData(startIdx+j,:);
            else
                decData.outcome(j).isActive=false;
                decData.outcome(j).execCount=0;
            end
            decData.outcome(j).justifiedExecCount=zeros(size(decData.outcome(j).execCount));
            [res,mode]=isFilteredOutcome(filteredOutcomes,filteredOutcomeModes,j);
            decData.outcome(j).isFiltered=0;
            decData.outcome(j).isJustified=0;
            if res
                decData.outcome(j).isFiltered=mode==0;
                decData.outcome(j).isJustified=mode==1;
                if decData.outcome(j).isJustified
                    if decData.outcome(j).execCount==0
                        decData.outcome(j).justifiedExecCount=decData.totals;
                        anyOutcomeJustified=true;
                        justifiedCnts=justifiedCnts+1;
                    else
                        decData.outcome(j).isJustified=0;
                    end
                end
            elseif decData.isJustified
                justifiedCnts=justifiedCnts+~decData.outcome(j).execCount;
            end

            decData.outcome(j).text=cvi.ReportUtils.getTextOf(decId,j-1,[],txtDetail);
            decData.outcome(j).linkStr='';
            decData.outcome(j).colorJustified=false;
            decData.outcome(j).executedIn=this.cvd{1}.getTrace(metricName,startIdx+j,true);
        end

        decData.outcome([decData.outcome.isFiltered]==1)=[];

        decData.executedIn='';
        decData.justifiedOutCnts=zeros(size(decData.outCnts));
        if(decData.isJustified||anyOutcomeJustified)&&any(~decData.covered)
            decData.justifiedOutCnts=justifiedCnts;
        else
            decData.isJustified=false;
        end

        decData.isFiltered=isempty(decData.outcome);

        decisions(i)=decData;%#ok<AGROW>

    end

    function[res,mode]=isFilteredOutcome(filteredOutcomes,filteredOutcomeModes,idx)
        res=false;
        mode=0;
        if~isempty(filteredOutcomes)
            fidx=find(filteredOutcomes==idx);
            if~isempty(fidx)
                res=true;
                mode=filteredOutcomeModes(fidx);
            end
        end



