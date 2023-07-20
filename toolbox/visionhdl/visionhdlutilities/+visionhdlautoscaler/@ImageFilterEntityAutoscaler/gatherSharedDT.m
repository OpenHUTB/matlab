function sharedLists=gatherSharedDT(this,blkObj)





    sharedLists={};
    sharedFirstInOutput=this.shareDataForSpecificPorts(isBlocksRequireSameDtFirstInputOutput(this,blkObj),1,1);
    sharedLists=this.hAppendToSharedLists(sharedLists,sharedFirstInOutput);

    if this.areCoefficientsSharing(blkObj)
        inportSet=this.hShareDTSpecifiedPorts(blkObj,1,[]);
        coeffSet=struct('blkObj',blkObj,'pathItem','Coefficients');
        inportSet=[inportSet,{coeffSet}];
        sharedLists=this.hAppendToSharedLists(sharedLists,inportSet);
    end
end







