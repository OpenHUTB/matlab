function[sharedLists]=gatherSharedDT(this,blockObject)




    sharedLists={};

    sharedSamePortSrc=hShareSrcAtSamePort(this,blockObject);
    sharedLists=this.hAppendToSharedLists(sharedLists,sharedSamePortSrc);


    if strcmp(blockObject.OutDataTypeStr,'Inherit: Same as first input')
        sharedParams=this.hShareDTSpecifiedPorts(blockObject,1,1);
        sharedLists=this.hAppendToSharedLists(sharedLists,sharedParams);
    end


    if strcmp(blockObject.InputSameDT,'on')
        sharedParams=this.hShareDTSpecifiedPorts(blockObject,-1,[]);
        sharedLists=this.hAppendToSharedLists(sharedLists,sharedParams);
    end
end