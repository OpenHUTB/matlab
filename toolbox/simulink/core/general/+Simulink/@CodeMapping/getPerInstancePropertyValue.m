function val=getPerInstancePropertyValue(modelH,mappedTo,propName)





    val='';
    if~isempty(mappedTo)
        if isa(mappedTo,'Simulink.DataReferenceClass')
            if~isempty(mappedTo.StorageClass)||~isempty(mappedTo.ServicePort)
                val=mappedTo.getCSCAttributeValue(modelH,propName);
            end
        elseif isa(mappedTo,'Simulink.AutosarTarget.DictionaryReference')
            val=mappedTo.getPerInstancePropertyValue(propName);
        end
    end
end
