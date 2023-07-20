function out=addMapping(this,dataReqSet,mapping)




    mfReqSet=dataReqSet.getModelObj();
    mfReqSet.mappings.add(mapping);

    out=true;
end
