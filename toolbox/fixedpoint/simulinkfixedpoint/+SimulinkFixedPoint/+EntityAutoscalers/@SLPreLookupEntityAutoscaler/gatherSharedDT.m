function sharedLists=gatherSharedDT(h,blkObj)






    sharedLists={};

    pathItems=getPathItems(h,blkObj);


    if ismember('Breakpoint',pathItems)...
        &&strcmp(blkObj.BreakpointDataTypeStr,'Inherit: Same as input')


        srcBlkRec=h.hShareDTSpecifiedPorts(blkObj,1,[]);
        if~isempty(srcBlkRec)

            paramRec.blkObj=blkObj;
            paramRec.pathItem='Breakpoint';
            sharedPair={srcBlkRec{1},paramRec};
            sharedLists=h.hAppendToSharedLists(sharedLists,sharedPair);
        end
    end
end
