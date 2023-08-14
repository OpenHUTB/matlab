function sharedLists=gatherSharedDT(h,blkObj)




    sharedLists={};

    paramRec{1}.blkObj=blkObj;
    paramRec{1}.pathItem='Table';
    paramRec{2}.blkObj=blkObj;
    paramRec{2}.pathItem='1';
    sharedLists{end+1}=paramRec;

    if(strcmp(blkObj.TableIsInput,'on'))

        sameDatatype=sameDataTypeForSpecificPorts(h,blkObj);
        if(~isempty(sameDatatype))
            sharedLists{end+1}=sameDatatype;
        end
    end

    sharedSamePortSrc=hShareSrcAtSamePort(h,blkObj);
    sharedLists=h.hAppendToSharedLists(sharedLists,sharedSamePortSrc);


    function sharedListPorts=sameDataTypeForSpecificPorts(h,blk)



        TablePort=numel(blk.PortHandles.Inport);
        sharedListPorts=h.hShareDTSpecifiedPorts(blk,TablePort,1);


