function ret=isPerInstanceProperty(modelH,mappingObj,member,propName)





    ret=false;
    if(isequal(member,'InitTermFunctions')||...
        isequal(member,'ExecutionFunctions')||...
        isequal(member,'SharedUtilityFunctions'))
        return;
    else
        obj=mappingObj.(member);
        if~isempty(obj)
            if isa(obj,'Simulink.DataReferenceClass')
                if~isempty(obj.StorageClass)||~isempty(obj.ServicePort)
                    ret=any(ismember(obj.getCSCAttributeNames(modelH),propName));
                end
            elseif isa(obj,'Simulink.AutosarTarget.DictionaryReference')
                if isa(mappingObj,'Simulink.AutosarTarget.AbstractParameterMapping')
                    ret=any(ismember(obj.getPerInstancePropertyNames(false),propName));
                else
                    ret=any(ismember(obj.getPerInstancePropertyNames(true),propName));
                end
            end
        end
    end
end
