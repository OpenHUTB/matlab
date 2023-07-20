function resetLinearModel(obj)




    obj.linearModel='';
    obj.linearModelVldn='';
    obj.SwitchesToLinearize={};
    obj.DiodesToLinearize={};
    obj.IGBTsTOLinearize={};
    obj.linearizationInfo=repmat(struct,numel(obj.DynamicSystemObj),1);

end

