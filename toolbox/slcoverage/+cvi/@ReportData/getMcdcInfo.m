function cvstruct=getMcdcInfo(this,cvstruct,mcdcentries,txtDetail,options)




    mcdcData=this.metricData.mcdc;
    mcdcCnt=length(mcdcentries);

    cvstruct.mcdcentries=struct(...
    'cvId',num2cell(mcdcentries),...
    'text',cell(1,mcdcCnt),...
    'numPreds',cell(1,mcdcCnt),...
    'predicate',cell(1,mcdcCnt),...
    'covered',cell(1,mcdcCnt),...
    'isJustifiedByParent',cell(1,mcdcCnt),...
    'isFilteredByParent',cell(1,mcdcCnt),...
    'isPositiveOnly',cell(1,mcdcCnt));

    testCnt=length(cvstruct.tests);
    if testCnt==1,
        coumnCnt=1;
    else
        coumnCnt=testCnt+1;
    end


    if options.cumulativeReport
        coumnCnt=testCnt;
    end;


    for i=1:mcdcCnt

        mcdcId=mcdcentries(i);
        [subconditions,numPreds,predAchievIdx,truePathIdx,falsePathIdx,activeCondIdx,hasVariableSize,isCascMCDC,cascMCDCBlocks,isPositiveOnly]=cv('get',mcdcId,...
        '.conditions',...
        '.numPredicates',...
        '.dataBaseIdx.predSatisfied',...
        '.dataBaseIdx.trueTableEntry',...
        '.dataBaseIdx.falseTableEntry',...
        '.dataBaseIdx.activeCondIdx',...
        '.hasVariableSize',...
        '.cascMCDC.isCascMCDC',...
        '.cascMCDC.memberBlocks',...
        '.isPositiveOnly');

        cvstruct.mcdcentries(i).cvId=mcdcId;
        cvstruct.mcdcentries(i).text=cvi.ReportUtils.getTextOf(mcdcId,-1,[],txtDetail);
        cvstruct.mcdcentries(i).numPreds=numPreds;
        cvstruct.mcdcentries(i).isPositiveOnly=isPositiveOnly;

        isActive=true;
        if hasVariableSize
            cvstruct.mcdcentries(i).isVariable=true;
            cvstruct.mcdcentries(i).isActive=any(mcdcData(activeCondIdx+1,end));
        else
            cvstruct.mcdcentries(i).isActive=~all(cv('get',subconditions,'.isDisabled'));
            cvstruct.mcdcentries(i).isVariable=false;
        end

        actCondIdx=0;
        if hasVariableSize
            actCondIdx=min(mcdcData(activeCondIdx+1,end));
        end

        cvstruct.mcdcentries(i).cascMCDC.isCascMCDC=isCascMCDC;
        cvstruct.mcdcentries(i).cascMCDC.memberBlocks=cascMCDCBlocks;


        blockCvId=cv('get',mcdcId,'.slsfobj');
        isBlockExcluded=cv('get',blockCvId,'.isDisabled');
        isBlockJustified=cv('get',blockCvId,'.isJustified');
        cvstruct.mcdcentries(i).isFilteredByParent=isBlockExcluded;
        cvstruct.mcdcentries(i).isJustifiedByParent=isBlockJustified;

        for k=1:numPreds
            condId=subconditions(k);

            predEntry.text=cvi.ReportUtils.getTextOf(condId,-1,[],txtDetail);
            predStatus=mcdcData(predAchievIdx+k,:);
            predEntry.achieved=(predStatus==SlCov.PredSatisfied.Fully_Satisfied)|...
            (isPositiveOnly&(predStatus==SlCov.PredSatisfied.True_Only));

            [~,isPredJustified]=SlCov.CoverageAPI.checkMcdcPredicateFiltering(...
            mcdcId,condId,k,isBlockExcluded,isBlockJustified,'');
            predEntry.isJustified=double(isPredJustified);

            predEntry.isVariable=false;
            isFiltered=~cv('get',condId,'.isDisabled');
            if hasVariableSize
                condIsActive=k<=actCondIdx;
                predEntry.isVariable=true;
            else
                condIsActive=isFiltered;
            end
            predEntry.isActive=isActive&condIsActive;

            for j=1:coumnCnt
                status=mcdcData(predAchievIdx+k,j);
                if status==0
                    true_text=getString(message('Slvnv:simcoverage:cvhtml:NA'));
                    false_text=getString(message('Slvnv:simcoverage:cvhtml:NA'));
                else
                    true_text=cv('McdcPathText',mcdcId,mcdcData(truePathIdx+k,j));
                    false_text=cv('McdcPathText',mcdcId,mcdcData(falsePathIdx+k,j));
                    if hasVariableSize
                        true_text=markUnusedConditions(this,true_text,subconditions,k);
                        false_text=markUnusedConditions(this,false_text,subconditions,k);
                    elseif isFiltered
                        true_text=markFilteredConditions(true_text,subconditions,k);
                        false_text=markFilteredConditions(false_text,subconditions,k);
                    else
                        true_text=make_n_bold(true_text,k);
                        false_text=make_n_bold(false_text,k);
                    end


                    if status==SlCov.PredSatisfied.Unsatisfied||status==SlCov.PredSatisfied.False_Only
                        true_text=['(',true_text,')'];
                    end

                    if status==SlCov.PredSatisfied.Unsatisfied||status==SlCov.PredSatisfied.True_Only
                        false_text=['(',false_text,')'];
                    end
                end
                predEntry.trueCombo{j}=true_text;
                predEntry.falseCombo{j}=false_text;

                predEntry.trueExecutedIn=this.cvd{1}.getTrace('mcdcTrue',predAchievIdx+k,true);
                predEntry.falseExecutedIn=this.cvd{1}.getTrace('mcdcFalse',predAchievIdx+k,true);
                predEntry.isPositiveOnly=isPositiveOnly;
            end

            if isempty(cvstruct.mcdcentries(i).predicate)
                cvstruct.mcdcentries(i).predicate=predEntry;
            else
                cvstruct.mcdcentries(i).predicate(end+1)=predEntry;
            end
        end
        if sum(mcdcData(predAchievIdx+1:numPreds,end)>0)==numPreds
            cvstruct.mcdcentries(i).covered=1;
        else
            cvstruct.mcdcentries(i).covered=0;
        end
    end

    function text=markFilteredConditions(text,subconditions,boldIdx)

        for k=1:numel(subconditions)
            condId=subconditions(k);
            if cv('get',condId,'.isDisabled')
                text(k)=' ';
            end
        end
        if boldIdx<=numel(text)
            text=make_n_bold(text,boldIdx);
        end



        function text=markUnusedConditions(this,text,subconditions,boldIdx)

            for k=1:numel(subconditions)
                condId=subconditions(k);
                condActiveCondIdx=cv('get',condId,'.coverage.activeCondIdx');
                if isfield(this.metricData,'condition')&&min(this.metricData.condition(condActiveCondIdx+1,end))==0
                    text(k)=' ';
                end
            end
            if boldIdx<=numel(text)
                text=make_n_bold(text,boldIdx);
            end





            function out=make_n_bold(str,n)
                if(n>length(str))
                    out=str;
                else
                    if(n==1)
                        out=sprintf('<font color="blue"><B>%s</B></font>%s',str(1),str(2:end));
                    elseif(n==length(str))
                        out=sprintf('%s<font color="blue"><B>%s</B></font>',str(1:(end-1)),str(end));
                    else
                        out=sprintf('%s<font color="blue"><B>%s</B></font>%s',str(1:(n-1)),str(n),str((n+1):end));
                    end
                end




