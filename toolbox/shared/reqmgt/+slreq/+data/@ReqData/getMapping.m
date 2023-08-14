function out=getMapping(this,dataReqSet,mappingName)





    out=[];

    mfReqSet=dataReqSet.getModelObj();
    mappings=mfReqSet.mappings.toArray();



    for n=1:length(mappings)
        mapping=mappings(n);
        if strcmp(mapping.name,mappingName)
            out=mapping;
            break;
        end
    end
end

