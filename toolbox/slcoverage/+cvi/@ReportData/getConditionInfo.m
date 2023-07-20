function cvstruct=getConditionInfo(this,cvstruct,conditions,txtDetail)







    condCnt=length(conditions);
    conditionData=this.metricData.condition;

    cvstruct.conditions=struct(...
    'cvId',num2cell(conditions),...
    'text',cell(1,condCnt),...
    'startChar',cell(1,condCnt),...
    'length',cell(1,condCnt),...
    'trueCnts',cell(1,condCnt),...
    'falseCnts',cell(1,condCnt),...
    'justifiedTrueCnts',cell(1,condCnt),...
    'justifiedFalseCnts',cell(1,condCnt),...
    'isJustifiedTrue',cell(1,condCnt),...
    'isJustifiedFalse',cell(1,condCnt),...
    'isJustifiedByParent',cell(1,condCnt),...
    'isFilteredByParent',cell(1,condCnt),...
    'isFiltered',cell(1,condCnt),...
    'isJustified',cell(1,condCnt),...
    'linkStr',cell(1,condCnt),...
    'linkStrTrue',cell(1,condCnt),...
    'linkStrFalse',cell(1,condCnt),...
    'filterRationale',cell(1,condCnt),...
    'isActive',cell(1,condCnt),...
    'isVariable',cell(1,condCnt),...
    'covered',cell(1,condCnt),...
    'trueExecutedIn',cell(1,condCnt),...
    'falseExecutedIn',cell(1,condCnt));


    for i=1:condCnt
        condId=conditions(i);
        condData=cvstruct.conditions(i);
        condData.cvId=condId;
        condData.text=cvi.ReportUtils.getTextOf(condId,-1,[],txtDetail);
        [condData.startChar,condData.length]=cv('get',cv('get',condId,'.descriptor'),'.startChar','.length');
        [trueCountIdx,falseCountIdx,activeCondIdx,hasVariableSize]=cv('get',condId,'.coverage.trueCountIdx','.coverage.falseCountIdx','.coverage.activeCondIdx','.hasVariableSize');
        condData.trueCnts=conditionData(trueCountIdx+1,:);
        condData.falseCnts=conditionData(falseCountIdx+1,:);
        condData.justifiedTrueCnts=zeros(size(condData.trueCnts));
        condData.justifiedFalseCnts=zeros(size(condData.falseCnts));
        totalCnts=condData.trueCnts+condData.falseCnts;
        condData.isActive=~cv('get',condId,'.isDisabled');
        condData.isVariable=hasVariableSize;
        if(hasVariableSize)
            condData.isActive=any(conditionData(activeCondIdx+1,:));
        end
        condData.covered=condData.trueCnts(end)>0&condData.falseCnts(end)>0;
        condData.trueExecutedIn=this.cvd{1}.getTrace('condition',trueCountIdx+1,true);
        condData.falseExecutedIn=this.cvd{1}.getTrace('condition',falseCountIdx+1,true);

        slsfObjId=cv('get',condId,'.slsfobj');
        condData.isJustifiedByParent=cv('get',slsfObjId,'.isJustified');
        condData.isFilteredByParent=cv('get',slsfObjId,'.isDisabled');
        condData.linkStr='';
        condData.linkStrTrue='';
        condData.linkStrFalse='';

        if~condData.isJustifiedByParent&&~condData.isFilteredByParent
            condData.filterRationale=cvi.ReportUtils.getFilterRationale(condId);
        else
            condData.filterRationale=cvi.ReportUtils.getFilterRationale(slsfObjId);
        end
        condData.isJustified=condData.isJustifiedByParent||cv('get',condId,'.isJustified');
        condData.isFiltered=condData.isFilteredByParent||cv('get',condId,'.isDisabled');

        if condData.isJustified&&(all(totalCnts)==0||any(~condData.covered))
            condData.isJustified=~condData.covered;
            condData.justifiedTrueCnts=totalCnts-condData.trueCnts;
            condData.justifiedFalseCnts=totalCnts-condData.falseCnts;
        else
            condData.isJustified=false;
        end

        condData=checkFilteredOutcome(condData,totalCnts,condId);


        cvstruct.conditions(i)=condData;
    end



    function condData=checkFilteredOutcome(condData,totalCnts,condId)
        filteredOutcomes=cv('get',condId,'.filteredOutcomes');
        condData.isJustifiedTrue=false;
        condData.isJustifiedFalse=false;
        if isempty(filteredOutcomes)
            return;
        end
        filteredOutcomeModes=cv('get',condId,'.filteredOutcomeModes');
        fidx=find(filteredOutcomes==1);
        if~isempty(fidx)
            modeTrue=filteredOutcomeModes(fidx);
            if(modeTrue==1)
                condData.justifiedTrueCnts=totalCnts-condData.trueCnts;
                if all(condData.trueCnts==0)
                    condData.isJustifiedTrue=true;
                end
            end
        end
        fidx=find(filteredOutcomes==2);
        if~isempty(fidx)
            modeFalse=filteredOutcomeModes(fidx);
            if(modeFalse==1)
                condData.justifiedFalseCnts=totalCnts-condData.falseCnts;
                if all(condData.falseCnts==0)
                    condData.isJustifiedFalse=true;
                end
            end
        end




