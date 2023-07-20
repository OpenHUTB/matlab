function conditionalPauseList=getConditionalPauseList(model)
    if isempty(model),return;end

    modelUDD=get_param(model.handle,'UDDObject');
    if isempty(modelUDD),return;end

    conditionalPauseList=get_param(modelUDD.Handle,'ConditionalPauseList');
end