function isValid=isCodeIdentifierValidProperty(indMapping)





    isValid=false;
    if~isempty(indMapping.MappedTo)
        mappedTo=indMapping.MappedTo.MappedTo;
        nonAutoSC=isequal(mappedTo,'StorageClass')...
        &&~isempty(indMapping.MappedTo.StorageClass);
        isValid=nonAutoSC||isequal(mappedTo,'ServicePort');
    end
end
