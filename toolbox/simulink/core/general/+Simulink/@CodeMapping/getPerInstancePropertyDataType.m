function val=getPerInstancePropertyDataType(modelH,mappedTo,propName)





    val='';
    if~isempty(mappedTo)
        if isa(mappedTo,'Simulink.DataReferenceClass')
            if~isempty(mappedTo.StorageClass)
                val=mappedTo.getCSCAttributeType(modelH,propName);
            end
        elseif isa(mappedTo,'Simulink.AutosarTarget.DictionaryReference')
            val=mappedTo.getPerInstancePropertyType(propName);
        end
    end
end
