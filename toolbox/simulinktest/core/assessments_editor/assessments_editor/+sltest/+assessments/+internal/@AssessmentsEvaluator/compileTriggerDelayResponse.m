function[code,data]=compileTriggerDelayResponse(self,trInfo)
    assert(strcmp(trInfo.operator,'trigger delay response'));
    data.context=sprintf('context%d',trInfo.id);
    data.name=trInfo.assessmentName;


    trigger=trInfo.children.trigger;
    data.trigger.label=trigger.operator;
    if isfield(trigger,'children')
        data.trigger.condition=trigger.children.condition;
        if isfield(trigger.children,'minTime')
            data.trigger.minTime=trigger.children.minTime;
        end
        if isfield(trigger.children,'maxTime')
            data.trigger.maxTime=trigger.children.maxTime;
        end


        if isfield(trigger.children,'timeReference')
            data.timereference=trigger.children.timeReference.operator;
        end
    end


    response=trInfo.children.response;
    data.response.label=response.operator;
    if isfield(response,'children')
        data.response.condition=response.children.condition;
        if isfield(response.children,'untilCondition')
            data.response.endCondition=response.children.untilCondition;
        end
        if isfield(response.children,'minTime')
            data.response.minTime=response.children.minTime;
        end
        if isfield(response.children,'maxTime')
            data.response.maxTime=response.children.maxTime;
        end
    end


    delay=trInfo.children.delay;
    data.delay.label=delay.operator;
    if isfield(delay,'children')
        if isfield(delay.children,'minTime')
            data.delay.minTime=delay.children.minTime;
        end
        if isfield(delay.children,'maxTime')
            data.delay.maxTime=delay.children.maxTime;
        end
    end

    [code,data]=self.triggerResponseCode(data);
end
