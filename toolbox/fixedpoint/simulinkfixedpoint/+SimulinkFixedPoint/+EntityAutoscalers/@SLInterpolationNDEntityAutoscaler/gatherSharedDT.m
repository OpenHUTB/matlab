function sharedLists=gatherSharedDT(h,blkObj)






    sharedLists={};

    outputID.blkObj=blkObj;
    outputID.pathItem='1';
    outputID.srcInfo=[];

    if strcmp(blkObj.TableSource,'Input port')







        tablePort=blkObj.Ports(1);
        sharedListPorts=h.hShareDTSpecifiedPorts(blkObj,tablePort,1);
        sharedLists=h.hAppendToSharedLists(sharedLists,sharedListPorts);
    end




    if~strcmp(blkObj.TableSpecification,'Lookup table object')&&...
        (strcmp(blkObj.TableSource,'Dialog')&&...
        strcmp(blkObj.TableDataTypeStr,'Inherit: Same as output'))
        paramRec.blkObj=blkObj;
        paramRec.pathItem='Table';
        paramRec.srcInfo=[];
        sharedLists=h.hAppendToSharedLists(sharedLists,{paramRec,outputID});
    end




    if strcmp(blkObj.IntermediateResultsDataTypeStr,'Inherit: Same as output')
        paramRec.blkObj=blkObj;
        paramRec.pathItem='Intermediate Results';
        paramRec.srcInfo=[];
        sharedLists=h.hAppendToSharedLists(sharedLists,{paramRec,outputID});
    end
end





