function res=getPatternErrorData(resultID,assessmentDefinition,clientResultDBGetter)





    res=[];
    if isa(resultID,'char')
        resultID=str2double(resultID);
    end

    getterFunc=str2func(clientResultDBGetter);


    warningState=warning('off','backtrace');
    expr=getterFunc(resultID);
    warning(warningState);

    if expr.internal.hasMetadata('extendedResult')
        globalSetting=sltest.assessments.internal.expression.minimizeUntestedTrace(expr.internal.hasMetadata('extendedResult'));
        restoreGlobalSetting=onCleanup(@()(sltest.assessments.internal.expression.minimizeUntestedTrace(globalSetting)));
    end


    if(~expr.internal.hasResults())
        expr.internal.verify();
    end

    errIntervals=expr.internal.errorIntervalList();

    if(numel(errIntervals)==1&&isinf(errIntervals(1).l)&&isinf(errIntervals(1).u))
        errIntervals(1).l=0;
        errIntervals(1).u=0;
    end


    if~isempty(errIntervals)

        if expr.internal.hasMetadata('patternType')
            patternType=expr.internal.metadata('patternType');
            if~isempty(patternType)&&strcmp(patternType,'boundsCheckPattern')
                res=getBoundsPatternData(expr,errIntervals,assessmentDefinition);
            else
                if isstruct(patternType)&&isfield(patternType,'trigger')
                    res=getTriggerResponsePatternData(expr,patternType,errIntervals,assessmentDefinition);
                end
            end
        end
    end
end



function patternData=evaluateTimeSymbolsInPattern(patternData,timeSymbols)%#ok<INUSD> used by eval bellow



    for timeField=["minTime","maxTime"]
        for patternField=["trigger","response","delay"]
            if isfield(patternData.(patternField),timeField)


                try
                    patternData.(patternField).(timeField)=eval(patternData.(patternField).(timeField));
                catch


                    patternData.(patternField).(timeField)=nan;
                end
            end
        end
    end
end


function res=getTriggerResponsePatternData(expr,patternData,errIntervals,assessmentDefinition)
    if isfield(assessmentDefinition,'TimeSymbols')
        patternData=evaluateTimeSymbolsInPattern(patternData,assessmentDefinition.TimeSymbols);
    else
        patternData=evaluateTimeSymbolsInPattern(patternData,[]);
    end

    context=sprintf('context%d',assessmentDefinition.Assessment.id);

    booleanResultNode=expr.expr;
    startTime=booleanResultNode.internal.startTime;
    endTime=booleanResultNode.internal.endTime;

    triggerCondition=getExprWithFlag(booleanResultNode,{'trigger_condition'},context);
    responseCondition=getExprWithFlag(booleanResultNode,{'response_condition'},context);
    responseEndCondition=getExprWithFlag(booleanResultNode,{'response_end_condition'},context);

    res=struct('tag',{},'trigger',{},'response',{},'responseend',{},'timereference',{},'delay',{},'explanation',{});

    errNumber=numel(errIntervals);

    errBound=min(errNumber,10);
    for idx=1:errBound
        triggerParams=getTriggerData(triggerCondition,errIntervals(idx).l,patternData.trigger);
        tmp.explanation.Header=getString(message('sltest:assessments:FailureAtTime',assessmentDefinition.Assessment.assessmentName,timeToHtmlString(triggerParams.l)));


        l=triggerParams.l;
        u=triggerParams.u;
        w=u-l;
        if w<(endTime-startTime)/500
            w=(endTime-startTime)/500;
        end
        l=max(startTime,l-w*0.1);
        u=min(endTime,u+w*0.1);

        triggerStruct.data=triggerCondition.internal.extractDataWindow(l,u,0);

        triggerStruct.data.Value=(triggerStruct.data.Value==sltest.assessments.Logical.True);
        triggerStruct.xDomain=[l,u];
        triggerStruct.triggerParams=triggerParams;
        tmp.trigger=triggerStruct;
        tmp.explanation.Trigger=getTriggerExplanation(triggerParams.l,patternData.trigger,triggerCondition.internal.stringLabel);

        timerefStruct.label='';
        if isfield(patternData,'timereference')
            timerefStruct.label=patternData.timereference;
        end

        timerefStruct.timeValue=getTimeReferenceValue(triggerStruct.triggerParams,timerefStruct.label);
        tmp.timereference=timerefStruct;

        tmp.delay=[0,0];
        if isfield(patternData.delay,'minTime')
            tmp.delay(1)=patternData.delay.minTime;
        end
        if isfield(patternData.delay,'maxTime')
            tmp.delay(2)=patternData.delay.maxTime;
        end

        delayStruct=getDelayData(timerefStruct.timeValue,patternData.delay);
        delayTimeExamples=delayStruct.minTime;


        if(delayStruct.maxTime>delayStruct.minTime)
            delayTimeExamples=getDelayExamples(responseCondition.internal.extractDataWindow(delayStruct.minTime,delayStruct.maxTime,0));
        end
        tmp.delay=delayStruct;

        tref=timerefStruct.label;
        if strcmp(patternData.trigger.label,'becomes true')
            tref='rising edge';
        end
        numDelayErr=numel(delayTimeExamples);

        for delayErrIdx=1:numDelayErr
            failureTime=delayTimeExamples(delayErrIdx);
            tmp.delay.failureTime=failureTime;
            tmp.explanation.Delay=getDelayExplanation(delayStruct,tref);
            responseParams=getResponseData(responseCondition,failureTime,failureTime,patternData.response);

            l=responseParams.l;
            u=responseParams.u;
            w=u-l;
            if w<(endTime-startTime)/500
                w=(endTime-startTime)/500;
            end
            u=min(endTime,u+w*0.1);

            responseStruct.data=responseCondition.internal.extractDataWindow(l,u,0);

            responseStruct.data.Value=(responseStruct.data.Value==sltest.assessments.Logical.True);
            responseStruct.xDomain=[l,u];
            responseStruct.responseParams=responseParams;
            tmp.responseend=[];
            if~isempty(responseEndCondition)
                tmp.responseend=responseEndCondition.internal.extractDataWindow(l,u,0);

                tmp.responseend.Value=(tmp.responseend.Value==sltest.assessments.Logical.True);
            end
            tmp.response=responseStruct;
            if numDelayErr>1
                errIdx=sprintf('%d.%d',idx,delayErrIdx);
            else
                errIdx=num2str(idx);
            end
            tmp.tag=getString(message('sltest:assessments:ErrorIndexLabel',errIdx,errNumber));
            responseEndDef='';
            if~isempty(responseEndCondition)
                responseEndDef=responseEndCondition.internal.stringLabel;
            end
            tmp.explanation.Response=getResponseExplanation(failureTime,responseCondition.internal.stringLabel,patternData.response,responseStruct.responseParams.failingTime,responseEndDef);
            res(end+1)=tmp;%#ok<AGROW>
        end
    end
end


function res=getDelayExamples(responseData)




    res=responseData.Time(end);
    w=0;
    t=[];
    for idx=1:numel(responseData.Time)
        if(responseData.Value(idx)==sltest.assessments.Logical.True)
            t=responseData.Time(idx);
        else
            if(responseData.Value(idx)==sltest.assessments.Logical.False)
                if~isempty(t)
                    wTmp=responseData.Time(idx)-t;
                    if(wTmp>w)
                        res=responseData.Time(idx-1);
                        w=wTmp;
                    end
                end
            end
        end
    end

end


function res=getTriggerExplanation(t,pattern,exprLabel)
    res=getString(message('sltest:assessments:TriggerIsTrueAtTime',exprLabel,timeToHtmlString(t)));

    switch pattern.label
    case 'whenever is true'

    case 'becomes true'

    case 'becomes true and stays true for at least'

    case 'becomes true and stays true for at most'

    case 'becomes true and stays true for between'

    otherwise
        assert(false,'Invalid pattern');
    end
end


function res=getDelayExplanation(delayStruct,timeRef)
    timeRef=erase(timeRef,' of trigger');
    switch delayStruct.label
    case 'with no delay'
        res.Header=getString(message('sltest:assessments:FailureResponseExpectedTrueAtTime',timeToHtmlString(delayStruct.minTime)));
        if(~isempty(timeRef))
            res.Explanation=getString(message('sltest:assessments:FailureNoDelayExplanation',timeRef));
        end
    case 'with a delay of at most'
        res.Header=getString(message('sltest:assessments:FailureResponseExpectedTrueInInterval',timeToHtmlString(delayStruct.minTime),timeToHtmlString(delayStruct.maxTime)));
        res.Explanation=getString(message('sltest:assessments:FailureAtMostDelayExplanation',timeToHtmlString(delayStruct.maxTimeRelative),timeRef));
    case 'with a delay of between'
        res.Header=getString(message('sltest:assessments:FailureResponseExpectedTrueInInterval',timeToHtmlString(delayStruct.minTime),timeToHtmlString(delayStruct.maxTime)));
        res.Explanation=getString(message('sltest:assessments:FailureAtBetweenDelayExplanation',timeToHtmlString(delayStruct.minTimeRelative),timeToHtmlString(delayStruct.maxTimeRelative),timeRef));
    otherwise
        assert(false,'Invalid pattern');
    end
end


function res=getResponseExplanation(t,def,pattern,failingTime,responseEndDef)
    switch pattern.label
    case 'must be true'
        res=getString(message('sltest:assessments:FailureResponseMustBeTrueExplanation',def,timeToErrorHtmlString(t)));
    case 'must stay true for at least'
        res=getString(message('sltest:assessments:FailureResponseMustBeTrueAtLeastExplanation',def,timeToHtmlString(t),timeToHtmlString(pattern.minTime),timeToErrorHtmlString(failingTime)));
    case 'must stay true for at most'
        if(failingTime<t+pattern.maxTime)
            res=getString(message('sltest:assessments:FailureResponseMustBeTrueAtMostExplanation1',def,timeToHtmlString(t),timeToHtmlString(pattern.maxTime),timeToErrorHtmlString(failingTime)));
        else
            res=getString(message('sltest:assessments:FailureResponseMustBeTrueAtMostExplanation2',def,timeToHtmlString(t),timeToHtmlString(pattern.maxTime),timeToErrorHtmlString(failingTime)));
        end
    case 'must stay true for between'
        if(failingTime<t+pattern.maxTime)
            res=getString(message('sltest:assessments:FailureResponseMustBeTrueBetweenExplanation1',def,timeToHtmlString(t),timeToHtmlString(pattern.minTime),timeToHtmlString(pattern.maxTime),timeToErrorHtmlString(failingTime)));
        else
            res=getString(message('sltest:assessments:FailureResponseMustBeTrueBetweenExplanation2',def,timeToHtmlString(t),timeToHtmlString(pattern.minTime),timeToHtmlString(pattern.maxTime),timeToErrorHtmlString(failingTime)));
        end
    case 'must stay true until'
        if(t==failingTime)


            res=strjoin({...
            getString(message('sltest:assessments:FailureResponseMustBeTrueUntilHeader',def,timeToHtmlString(t),responseEndDef,timeToHtmlString(pattern.maxTime))),...
            getString(message('sltest:assessments:FailureResponseMustBeTrueUntilExplanation1',def,timeToErrorHtmlString(failingTime)))...
            },'\n');
        else
            if(failingTime<t+pattern.maxTime)


                res=strjoin({...
                getString(message('sltest:assessments:FailureResponseMustBeTrueUntilHeader',def,timeToHtmlString(t),responseEndDef,timeToHtmlString(pattern.maxTime))),...
                getString(message('sltest:assessments:FailureResponseMustBeTrueUntilExplanation2',def,timeToErrorHtmlString(failingTime),responseEndDef))...
                },'\n');
            else



                res=strjoin({...
                getString(message('sltest:assessments:FailureResponseMustBeTrueUntilHeader',def,timeToHtmlString(t),responseEndDef,timeToHtmlString(pattern.maxTime))),...
                getString(message('sltest:assessments:FailureResponseMustBeTrueUntilExplanation3',def,timeToHtmlString(t),timeToErrorHtmlString(failingTime),responseEndDef))...
                },'\n');
            end
        end
    otherwise
        assert(false,'Invalid pattern');
    end
end


function res=getTriggerData(expr,startT,pattern)

    r=expr.internal.results();
    idx=1;
    while(idx<numel(r.Time)&&r.Time(idx)<startT)
        idx=idx+1;
    end
    assert(idx<=numel(r.Time),'Expected error start time not found in result');
    if(idx<numel(r.Time))
        if(r.Time(idx)>startT)
            fallingEdgeT=r.Time(idx);
        else
            fallingEdgeT=r.Time(idx+1);
        end
    else
        fallingEdgeT=r.Time(end);
    end

    switch pattern.label
    case 'whenever is true'
        if fallingEdgeT>startT
            endT=fallingEdgeT;
        else
            endT=startT;
        end
        res.risingTime=startT;
    case 'becomes true'
        endT=fallingEdgeT;
        res.risingTime=startT;
    case 'becomes true and stays true for at least'
        res.risingTime=startT;
        minTime=pattern.minTime;
        if startT+minTime*2<fallingEdgeT
            endT=startT+minTime*2;
        else
            endT=fallingEdgeT;
        end
        res.minTime=startT+minTime;
        res.minTimeRelative=minTime;
    case 'becomes true and stays true for at most'
        res.risingTime=startT;
        res.fallingTime=fallingEdgeT;
        maxTime=pattern.maxTime;
        res.maxTime=startT+maxTime;
        endT=res.maxTime;
        res.maxTimeRelative=maxTime;
    case 'becomes true and stays true for between'
        res.risingTime=startT;
        res.fallingTime=fallingEdgeT;
        minTime=pattern.minTime;
        maxTime=pattern.maxTime;
        res.minTime=startT+minTime;
        res.minTimeRelative=minTime;
        res.maxTime=startT+maxTime;
        res.maxTimeRelative=maxTime;
        endT=res.maxTime;
    otherwise
        assert(false,'Invalid pattern');
    end

    res.l=startT;
    res.u=endT;
    res.pattern=pattern.label;

end


function res=getResponseData(expr,delayL,delayU,pattern)
    switch pattern.label
    case 'must be true'
        startT=delayL;
        endT=delayU;
        res.failingTime=delayU;
    case 'must stay true for at least'
        startT=delayL;
        res.minTimeRelative=pattern.minTime;
        res.minTime=delayU+res.minTimeRelative;
        endT=res.minTime;
        d=expr.internal.extractDataWindow(delayU,res.minTime,0);
        if(d.Value(1)==sltest.assessments.Logical.False)
            res.failingTime=d.Time(1);
        else
            res.failingTime=d.Time(2);
        end
    case 'must stay true for at most'
        startT=delayL;
        res.maxTimeRelative=pattern.maxTime;
        res.maxTime=delayU+res.maxTimeRelative;
        endT=res.maxTime;
        d=expr.internal.extractDataWindow(delayU,res.maxTime,0);
        if(d.Value(1)==sltest.assessments.Logical.False)
            res.failingTime=d.Time(1);
        else
            res.failingTime=res.maxTime;
        end
    case 'must stay true for between'
        startT=delayL;
        res.minTimeRelative=pattern.minTime;
        res.minTime=delayU+res.minTimeRelative;
        res.maxTimeRelative=pattern.maxTime;
        res.maxTime=delayU+res.maxTimeRelative;
        endT=res.maxTime;
        d=expr.internal.extractDataWindow(delayU,res.maxTime,0);
        if(d.Value(1)==sltest.assessments.Logical.False)
            res.failingTime=d.Time(1);
        else
            if(numel(d.Time)==1)
                res.failingTime=res.maxTime;
            else
                res.failingTime=d.Time(2);
            end
        end
    case 'must stay true until'
        startT=delayL;
        res.maxTimeRelative=pattern.maxTime;
        res.maxTime=delayU+res.maxTimeRelative;
        endT=res.maxTime;
        d=expr.internal.extractDataWindow(startT,endT,0);
        if(d.Value(1)==sltest.assessments.Logical.False)


            res.failingTime=d.Time(1);
        else
            if(numel(d.Value)>1)


                res.failingTime=d.Time(2);
            else



                res.failingTime=endT;
            end
        end
    otherwise
        assert(false,'Invalid pattern');
    end
    res.l=startT;
    res.u=endT;
    res.pattern=pattern.label;
end


function res=getTimeReferenceValue(triggerParams,pattern)
    switch pattern
    case ''
        res=triggerParams.l;
    case 'rising edge of trigger'
        res=triggerParams.risingTime;
    case 'falling edge of trigger'
        res=triggerParams.fallingTime;
    case 'end of max-time'
        res=triggerParams.maxTime;
    case 'end of min-time'
        res=triggerParams.minTime;
    otherwise
        assert(false,'invalid timereference')
    end
end


function res=getDelayData(timeRefVal,pattern)
    res.label=pattern.label;
    switch pattern.label
    case 'with no delay'
        res.minTime=timeRefVal;
        res.maxTime=timeRefVal;
        res.minTimeRelative=0;
        res.maxTimeRelative=0;
    case 'with a delay of at most'
        res.minTime=timeRefVal;
        res.maxTime=timeRefVal+pattern.maxTime;
        res.minTimeRelative=0;
        res.maxTimeRelative=pattern.maxTime;
    case 'with a delay of between'
        res.minTime=timeRefVal+pattern.minTime;
        res.maxTime=timeRefVal+pattern.maxTime;
        res.minTimeRelative=pattern.minTime;
        res.maxTimeRelative=pattern.maxTime;
    otherwise
        assert(false,'Invalid pattern');
    end
end




function res=getBoundsPatternData(expr,errIntervals,assessmentDefinition)
    context=sprintf('context%d',assessmentDefinition.Assessment.id);



    booleanResultNode=expr.expr;
    boolres=booleanResultNode.internal.results();
    startTime=booleanResultNode.internal.startTime;
    endTime=booleanResultNode.internal.endTime;

    removeExamples=false;
    if(isinf(startTime))
        startTime=0;
        removeExamples=true;
    end
    if(isinf(endTime))
        endTime=0;
        removeExamples=true;
    end
    xDomain=[startTime,endTime];

    patternType=booleanResultNode.getPatternFlag(context,'patternOperator');
    assert(numel(patternType)==1,'Unexpected bounds pattern result');
    patternType=patternType{1};


    signal=getExprWithFlag(booleanResultNode,{'boundsCheckPattern','signal'},context);
    lowerBound=getExprWithFlag(booleanResultNode,{'boundsCheckPattern','lowerBound'},context);
    upperBound=getExprWithFlag(booleanResultNode,{'boundsCheckPattern','upperBound'},context);


    res=getErrorResult(boolres,signal,startTime,endTime,lowerBound,upperBound);
    res.tag=getString(message('sltest:assessments:OverallResultLabel'));
    res.explanation='';
    res.errIntervals=errIntervals;

    errNumber=numel(errIntervals);
    errBound=min(errNumber,10);
    for idx=1:errBound
        l=errIntervals(idx).l;
        u=errIntervals(idx).u;

        if(isinf(l))
            l=0;
        end
        if(isinf(u))
            u=0;
        end

        w=u-l;
        if w<10*eps(u)
            w=0.1;
        end
        startTime=max(xDomain(1),l-w*0.1);
        endTime=min(xDomain(2),u+w*0.1);
        booltmp=booleanResultNode.internal.extractDataWindow(l,u,0);
        tmp=getErrorResult(booltmp,signal,startTime,endTime,lowerBound,upperBound);
        tmp.tag=getString(message('sltest:assessments:ErrorIndexLabel',idx,errNumber));
        tmp.explanation=getBoundsExplanation(patternType,tmp,assessmentDefinition,l,u);
        tmp.errIntervals=errIntervals(idx);
        res(end+1)=tmp;%#ok<AGROW>
    end
    explanation.Header=getString(message('sltest:assessments:FailureAllInterval',assessmentDefinition.Assessment.assessmentName));
    explanation.Expected=res(2).explanation.Expected;
    explanation.Examples=arrayfun(@(x)x.explanation.Examples,res(2:end),'UniformOutput',0);


    vacStr={};
    if(strcmp(patternType,'always inside bounds'))
        tmp=upperBound>lowerBound;
        tmp.internal.verify;
        vacIntervals=tmp.internal.errorIntervalList();
        lowerBoundName=res(1).lowerBound.Name;
        upperBoundName=res(1).upperBound.Name;

        for idx=1:numel(vacIntervals)
            l=timeToHtmlString(vacIntervals(idx).l);
            u=timeToHtmlString(vacIntervals(idx).u);
            vacStr{end+1}=getString(message('sltest:assessments:FailureAlwaysFalseInside',assessmentDefinition.Assessment.assessmentName,l,u,lowerBoundName,upperBoundName));%#ok<AGROW>
        end
    end
    explanation.Warnings=vacStr;
    res(1).explanation=explanation;
    if removeExamples
        res=res(1);
    end
end


function res=getBoundsExplanation(pattern,result,assessmentDefinition,l,u)

    function header=getHeader(name,a,b)
        if(b-a)<=eps(b)
            header=getString(message('sltest:assessments:FailureSingularPoint',name,timeToHtmlString(a)));
        else
            header=getString(message('sltest:assessments:FailureInterval',name,timeToHtmlString(a),timeToHtmlString(b)));
        end
    end

    function msg=getPatternMessageId(p,example)
        if nargin<2
            example=false;
        end
        lowerBoundType='';
        upperBoundType='';
        node=assessmentDefinition.Assessment.children.boundsCheckPattern.children;
        if isfield(node,'lowerBoundType')
            if strcmp(node.lowerBoundType.dataType,'lower-bound-clause')
                if strcmp(node.lowerBoundType.operator,'greater than')
                    lowerBoundType='Greater';
                else
                    lowerBoundType='GreaterOrEqual';
                end
            else
                if strcmp(node.lowerBoundType.operator,'less than')
                    lowerBoundType='Less';
                else
                    lowerBoundType='LessOrEqual';
                end
            end
        end
        if isfield(node,'upperBoundType')
            if strcmp(node.upperBoundType.dataType,'upper-bound-clause')
                if strcmp(node.upperBoundType.operator,'less than')
                    upperBoundType='Less';
                else
                    upperBoundType='LessOrEqual';
                end
            else
                if strcmp(node.upperBoundType.operator,'greater than')
                    upperBoundType='Greater';
                else
                    upperBoundType='GreaterOrEqual';
                end
            end
        end
        switch p
        case 'always less than'
            msg=sprintf('sltest:assessments:FailureExpected%s',upperBoundType);
        case 'always greater than'
            msg=sprintf('sltest:assessments:FailureExpected%s',lowerBoundType);
        case 'always inside bounds'
            msg=sprintf('sltest:assessments:FailureExpected%sAnd%s',lowerBoundType,upperBoundType);
        case 'always outside bounds'
            msg=sprintf('sltest:assessments:FailureExpected%sOr%s',lowerBoundType,upperBoundType);
        otherwise
            msg='';
        end
        if example
            msg=sprintf('%s%s',msg,'Example');
        end
    end






    idxToConsider=(result.signal.Time>=l&result.signal.Time<=u);
    timeToConsider=result.signal.Time(idxToConsider);
    valueToConsider=result.signal.Value(idxToConsider);
    if isfield(result,'lowerBound')
        lowerValueToConsider=result.lowerBound.Value(idxToConsider);
    else
        lowerValueToConsider=[];
    end
    if isfield(result,'upperBound')
        upperValueToConsider=result.upperBound.Value(idxToConsider);
    else
        upperValueToConsider=[];
    end
    switch pattern
    case 'always less than'
        res.Header=getHeader(assessmentDefinition.Assessment.assessmentName,l,u);
        res.Expected=getString(message(getPatternMessageId(pattern),result.signal.Name,result.upperBound.Name));
        [~,idx]=min(upperValueToConsider-valueToConsider);
        res.Examples=getString(message(getPatternMessageId(pattern,true),timeToHtmlString(timeToConsider(idx)),valueToHtmlString(upperValueToConsider(idx)),valueToHtmlString(valueToConsider(idx),true)));
    case 'always greater than'
        res.Header=getHeader(assessmentDefinition.Assessment.assessmentName,l,u);
        res.Expected=getString(message(getPatternMessageId(pattern),result.signal.Name,result.lowerBound.Name));

        [~,idx]=min(valueToConsider-lowerValueToConsider);
        res.Examples=getString(message(getPatternMessageId(pattern,true),timeToHtmlString(timeToConsider(idx)),valueToHtmlString(lowerValueToConsider(idx)),valueToHtmlString(valueToConsider(idx),true)));
    case 'always inside bounds'
        res.Header=getHeader(assessmentDefinition.Assessment.assessmentName,l,u);
        res.Expected=getString(message(getPatternMessageId(pattern),result.signal.Name,result.lowerBound.Name,result.upperBound.Name));

        [lowerdiff,idx]=min(valueToConsider-lowerValueToConsider);
        if lowerdiff>=0
            [upperdiff,idx2]=min(upperValueToConsider-valueToConsider);
            if(upperdiff<lowerdiff)
                idx=idx2;
            end
        end
        res.Examples=getString(message(getPatternMessageId(pattern,true),timeToHtmlString(timeToConsider(idx)),valueToHtmlString(lowerValueToConsider(idx)),valueToHtmlString(upperValueToConsider(idx)),valueToHtmlString(valueToConsider(idx),true)));
    case 'always outside bounds'
        res.Header=getHeader(assessmentDefinition.Assessment.assessmentName,l,u);
        res.Expected=getString(message(getPatternMessageId(pattern),result.signal.Name,result.lowerBound.Name,result.upperBound.Name));

        lowerdiff=lowerValueToConsider-valueToConsider;
        upperdiff=valueToConsider-upperValueToConsider;
        [~,idx]=min(max(lowerdiff,upperdiff));
        res.Examples=getString(message(getPatternMessageId(pattern,true),timeToHtmlString(timeToConsider(idx)),valueToHtmlString(lowerValueToConsider(idx)),valueToHtmlString(upperValueToConsider(idx)),valueToHtmlString(valueToConsider(idx),true)));
    otherwise
        res='';
    end
end


function res=getErrorResult(boolres,signal,startTime,endTime,lowerBound,upperBound)

    res=getResultStruct(signal,startTime,endTime);


    timeUnion=union(res.signal.Time,boolres.Time);
    if~isempty(lowerBound)
        resLowerBound=getResultStruct(lowerBound,res.xDomain(1),res.xDomain(2));

        boundMargin=abs(resLowerBound.yDomain(2)-res.yDomain(2));
        if boundMargin==0
            boundMargin=1;
        end
        yDomainUpper=resLowerBound.yDomain(2)+boundMargin;
        res.yDomain=[min(resLowerBound.yDomain(1),res.yDomain(1)),...
        max(yDomainUpper,res.yDomain(2))];
        timeUnion=union(timeUnion,resLowerBound.signal.Time);

        res.lowerBound=resLowerBound.signal;
    end
    if~isempty(upperBound)
        resUpperBound=getResultStruct(upperBound,res.xDomain(1),res.xDomain(2));

        boundMargin=abs(resUpperBound.yDomain(2)-res.yDomain(2));
        if boundMargin==0
            boundMargin=1;
        end
        yDomainLower=resUpperBound.yDomain(1)-boundMargin;
        res.yDomain=[min(yDomainLower,res.yDomain(1)),...
        max(resUpperBound.yDomain(2),res.yDomain(2))];
        timeUnion=union(timeUnion,resUpperBound.signal.Time);

        res.upperBound=resUpperBound.signal;
    end





    for field={'signal','lowerBound','upperBound'}
        if isfield(res,field{1})
            res.(field{1})=resampleWithFailureTimePoint(res.(field{1}),timeUnion);
        end
    end
end


function res=getResultStruct(signal,l,u)
    if nargin==1
        res.signal=signal.internal.results();
    else
        res.signal=signal.internal.extractDataWindow(l,u,(u-l)/500);
    end
    res.signal.InterpMethod=res.signal.Interpolation;
    if isfi(res.signal.Value)
        res.signal.Value=double(res.signal.Value);
    end
    res.xDomain=[res.signal.Time(1),res.signal.Time(end)];
    res.yDomain=[min(res.signal.Value),max(res.signal.Value)];
    if signal.internal.hasMetadata('originalEnumType')
        res.enumDefinition=signal.internal.metadata('originalEnumType');
    end
end


function result=resampleWithFailureTimePoint(result,timeVect)
    idx=find(timeVect>=result.Time(end),1);

    ts=setinterpmethod(timeseries(result.Value,result.Time),result.Interpolation);
    ts=resample(ts,timeVect(1:idx));
    result.Value=squeeze(ts.Data);
    result.Time=squeeze(ts.Time);
end


function res=getExprWithFlag(expr,flag,context)
    res=[];

    currentflags=expr.getPatternFlag(context,'patternFlag');
    if find(ismember(currentflags,flag{1}))
        flag(1)=[];
        if(isempty(flag))
            res=expr;
            return;
        end
    end

    if(~isempty(expr.children))
        for c=expr.children
            res=getExprWithFlag(c{1},flag,context);
            if(~isempty(res))
                return;
            end
        end
    end
end

function res=timeToHtmlString(t)
    if isnumeric(t)
        res=sprintf('<b>%.15g s</b>',t);
    else
        res=sprintf('<b>%s s</b>',t);
    end
end

function res=timeToErrorHtmlString(t)
    res=sprintf('<font color="red"><b>%.15g s</b></font>',t);
end

function res=valueToHtmlString(v,red)
    if nargin<2
        red=false;
    end
    if islogical(v)
        s=mat2str(v);
    else
        s=sprintf('%.15g',v);
    end
    res=sprintf('<b>%s</b>',s);
    if(red)
        res=sprintf('<font color="red">%s</font>',res);
    end
end
