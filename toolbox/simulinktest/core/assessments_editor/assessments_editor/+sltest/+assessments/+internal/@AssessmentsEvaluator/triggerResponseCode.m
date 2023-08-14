function[code,data]=triggerResponseCode(self,data)
    code={};
    if isfield(data,'context')
        context=data.context;
    else

        context='context';
    end



    triggerIdToOperator=containers.Map(...
    {'whenever is true',...
    'becomes true',...
    'becomes true and stays true for at least',...
    'becomes true and stays true for at most',...
    'becomes true and stays true for between'},...
...
    {'sltest.assessments.WheneverIsTrue(%condition%)',...
    'sltest.assessments.BecomesTrue(%condition%)',...
    'sltest.assessments.BecomesTrueAndStaysTrueForAtLeast(%min-time%,%condition%)',...
    'sltest.assessments.BecomesTrueAndStaysTrueForAtMost(%max-time%,%condition%)',...
    'sltest.assessments.BecomesTrueAndStaysTrueForBetween([%min-time%, %max-time%], %condition%)'}...
    );

    responseIdToOperator=containers.Map(...
    {'must be true',...
    'must stay true for at least',...
    'must stay true for at most',...
    'must stay true for between',...
    'must stay true until'},...
...
    {'sltest.assessments.IsTrue(%condition%)',...
    'sltest.assessments.IsTrueAndStaysTrueForAtLeast(%min-time%,%condition%)',...
    'sltest.assessments.IsTrueAndStaysTrueForAtMost(%max-time%,%condition%)',...
    'sltest.assessments.IsTrueAndStaysTrueForBetween([%min-time%, %max-time%], %condition%)',...
    'sltest.assessments.IsTrueAndStaysTrueUntil(%condition%, %max-time%, %end-condition%)'}...
    );



    triggerConditionVarName=self.makeTempVar('trigger_condition');
    if isfield(data.trigger,'condition')
        triggerCondition=self.compileExpression(data.trigger.condition,'trigger');
        code{end+1}=sprintf('%s = %s;',triggerConditionVarName,triggerCondition);
        code{end+1}=sprintf('%s.addPatternFlag(''%s'',''patternFlag'',''trigger_condition'');',triggerConditionVarName,context);
    end


    responseConditionVarName=self.makeTempVar('response_condition');
    if isfield(data.trigger,'condition')
        responseCondition=self.compileExpression(data.response.condition,'response');
        code{end+1}=sprintf('%s = %s;',responseConditionVarName,responseCondition);
        code{end+1}=sprintf('%s.addPatternFlag(''%s'',''patternFlag'',''response_condition'');',responseConditionVarName,context);
    end



    if~isempty(data.response.label)
        responseCode=responseIdToOperator(data.response.label);
        responseCode=strrep(responseCode,'%condition%',responseConditionVarName);

        if isfield(data.response,'endCondition')
            responseEndConditionVarName=self.makeTempVar('response_end_condition');
            responseCode=strrep(responseCode,'%end-condition%',responseEndConditionVarName);

            code{end+1}=sprintf('%s = %s;',responseEndConditionVarName,self.compileExpression(data.response.endCondition,'response'));
            code{end+1}=sprintf('%s.addPatternFlag(''%s'',''patternFlag'',''response_end_condition'');',responseEndConditionVarName,context);
        end
        if isfield(data.response,'minTime')
            data.response.minTime=self.compileTime(data.response.minTime,'response');
            responseCode=strrep(responseCode,'%min-time%',data.response.minTime);
        end
        if isfield(data.response,'maxTime')
            data.response.maxTime=self.compileTime(data.response.maxTime,'response');
            responseCode=strrep(responseCode,'%max-time%',data.response.maxTime);
        end
    else
        self.addError('sltest:assessments:EmptyOperatorError','response');
        responseCode='<missing>';
    end
    responseVarName=self.makeTempVar('response');
    code{end+1}=sprintf('%s = %s;',responseVarName,responseCode);



    if isfield(data.delay,'minTime')
        data.delay.minTime=self.compileTime(data.delay.minTime,'delay');
    end
    if isfield(data.delay,'maxTime')
        data.delay.maxTime=self.compileTime(data.delay.maxTime,'delay');
    end
    switch data.delay.label
    case 'with no delay'
        delayVarExpr=sprintf('sltest.assessments.WithNoDelay(%s)',responseVarName);
    case 'with a delay of at most'
        delayVarExpr=sprintf('sltest.assessments.AfterAtMostDelay(%s, %s)',data.delay.maxTime,responseVarName);
    case 'with a delay of between'
        delayVarExpr=sprintf('sltest.assessments.AfterBetweenDelay([%s, %s], %s)',data.delay.minTime,data.delay.maxTime,responseVarName);
    otherwise
        assert(false,'unexpected delay %s',data.delay.label);
    end
    delayVarName=self.makeTempVar('delay');
    code{end+1}=sprintf('%s = %s;',delayVarName,delayVarExpr);



    if~isempty(data.trigger.label)
        triggerCode=triggerIdToOperator(data.trigger.label);
        triggerCode=strrep(triggerCode,'%condition%',triggerConditionVarName);
        if isfield(data.trigger,'minTime')
            data.trigger.minTime=self.compileTime(data.trigger.minTime,'trigger');
            triggerCode=strrep(triggerCode,'%min-time%',data.trigger.minTime);
        end
        if isfield(data.trigger,'maxTime')
            data.trigger.maxTime=self.compileTime(data.trigger.maxTime,'trigger');
            triggerCode=strrep(triggerCode,'%max-time%',data.trigger.maxTime);
        end
    else
        self.addError('sltest:assessments:EmptyOperatorError','trigger');
        triggerCode='<missing>';
    end
    triggerVarName=self.makeTempVar('trigger');
    code{end+1}=sprintf('%s = %s;',triggerVarName,triggerCode);


    LogicalStr={'false','true'};
    triggerIsDiscrete=LogicalStr{1+~strcmp(data.trigger.label,'whenever is true')};

    timeRefVarName=self.makeTempVar('time_ref');
    if~isfield(data,'context')&&isfield(data,'timereference')&&isempty(data.timereference)


        data=rmfield(data,'timereference');
    end
    if isfield(data,'timereference')
        if~isempty(data.timereference)
            switch data.timereference
            case 'rising edge of trigger'
                code{end+1}=sprintf('%s = sltest.assessments.IfThenAtRisingEdge(%s, %s, %s);',timeRefVarName,triggerVarName,delayVarName,triggerIsDiscrete);
            case 'falling edge of trigger'
                code{end+1}=sprintf('%s = sltest.assessments.IfThenAtFallingEdge(%s, %s, %s, %s, %s);',timeRefVarName,triggerVarName,delayVarName,triggerConditionVarName,data.trigger.maxTime,triggerIsDiscrete);
            case 'end of min-time'
                code{end+1}=sprintf('%s = sltest.assessments.IfThenAfter(%s, %s, %s, %s, %s);',timeRefVarName,triggerVarName,delayVarName,data.trigger.minTime,'''end of min-time''',triggerIsDiscrete);
            case 'end of max-time'
                code{end+1}=sprintf('%s = sltest.assessments.IfThenAfter(%s, %s, %s, %s, %s);',timeRefVarName,triggerVarName,delayVarName,data.trigger.maxTime,'''end of max-time''',triggerIsDiscrete);
            otherwise
                assert(false,'unexpected time reference %s',data.timereference);
            end
        else
            self.addError('sltest:assessments:EmptyOperatorError','time-reference');
            code{end+1}=sprintf('%s = <missing>;',timeRefVarName);
        end
    else
        code{end+1}=sprintf('%s = sltest.assessments.IfThen(%s, %s, %s);',timeRefVarName,triggerVarName,delayVarName,triggerIsDiscrete);
    end



    name=strrep(strrep(data.name,'''',''''''),newline,' ');
    code{end+1}=sprintf('%s = sltest.assessments.Alias(%s, ''%s: At any point in time, '', %s);',self.namespaces.output,timeRefVarName,name,timeRefVarName);
    code{end+1}=sprintf('%s.internal.setMetadata(''patternType'', patternData);',self.namespaces.output);

    code=strjoin(code,newline);
end
