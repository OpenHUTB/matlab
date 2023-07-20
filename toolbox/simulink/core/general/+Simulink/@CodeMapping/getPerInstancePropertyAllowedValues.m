function values=getPerInstancePropertyAllowedValues(modelH,mappedTo,propName)





    values={};
    if~isempty(mappedTo)
        if isa(mappedTo,'Simulink.DataReferenceClass')
            if~isempty(mappedTo.StorageClass)
                values=mappedTo.getCSCAttributeAllowedValues(modelH,propName);
            end
        elseif isa(mappedTo,'Simulink.AutosarTarget.DictionaryReference')
            values=mappedTo.getPerInstancePropertyAllowedValues(propName);
        end
    end
end
