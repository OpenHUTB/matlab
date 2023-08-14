function cvstruct=getTestobjectiveInfo(this,cvstruct,testobjectives,metricName)




    txtDetail=2;
    toData=this.testobjectiveData.(metricName);
    for i=1:length(testobjectives)
        testobjectiveId=testobjectives(i);
        testobjData=[];
        testobjData.cvId=testobjectiveId;
        testobjData.text='';
        isJustified=cv('get',cv('get',testobjectiveId,'.slsfobj'),'.isJustified');
        [startIdx,showOnlyTrueOutcome]=cv('get',testobjectiveId,'.dc.baseIdx','.dc.showTrueOutcome');
        testobjData.collapseVector=cv('get',testobjectiveId,'.collapseVector');

        if~showOnlyTrueOutcome
            testobjData=getDecisionInfo(this,metricName,toData,testobjectiveId,txtDetail);
            testobjData.showOnlyTrueOutcome=false;
            if strcmpi(metricName,'cvmetric_Structural_block')
                emlLinesTxt=getEMLLines(testobjectiveId);
                if~isempty(emlLinesTxt)
                    testobjData.text=emlLinesTxt;
                end
            end
        else
            testobjData.showOnlyTrueOutcome=true;
            falseCount=0;
            trueCount=toData(startIdx+2,:);
            testobjData.text=cvi.ReportUtils.getTextOf(testobjectiveId,-1,[],txtDetail);
            testobjData.execCount=toData(startIdx+1,:)+toData(startIdx+2,:);
            testobjData.hitTrueCount=trueCount;
            testobjData.hitFalseCount=falseCount;
            testobjData.countOfExecutedOutcomes=(trueCount>0)+(falseCount>0);
            testobjData.covered=(trueCount>0);

            testobjData.justifiedExecCount=zeros(size(testobjData.execCount));
            testobjData.isJustified=isJustified;
            if isJustified&&any(~testobjData.covered)
                testobjData.justifiedExecCount=testobjData.hitTrueCount-testobjData.execCount;
            end
            testobjData.executedIn=this.cvd{1}.getTrace(metricName,startIdx+2,true);
        end
        cvstruct.(metricName)(i)=testobjData;

    end

    function text=getEMLLines(testobjectiveId)
        descId=cv('get',testobjectiveId,'.descriptor');
        formId=cv('get',descId,'.formatter');
        text='';
        if cv('get',formId,'.isa')==cv('get','default','codeblock.isa')
            codeblockId=formId;
            intParams=cv('get',descId,'.intParams');
            startLine=cv('CodeBloc','char2line',codeblockId,intParams(1));
            endLine=cv('CodeBloc','char2line',codeblockId,intParams(2));
            text=sprintf('line #%d - line #%d',startLine,endLine);

        end




