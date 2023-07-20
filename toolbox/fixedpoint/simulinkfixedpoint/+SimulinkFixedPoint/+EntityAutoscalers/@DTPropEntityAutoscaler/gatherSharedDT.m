function sharedLists=gatherSharedDT(h,blkObj)




    sharedLists={};

    if isequal(blkObj.PropDataTypeMode,'Specify via dialog')&&...
        isequal(blkObj.PropScalingMode,'Specify via dialog')
        dtlist=h.hShareDTSpecifiedPorts(blkObj,3,[]);
        if~isempty(dtlist)
            localResult.blkObj=blkObj;
            localResult.pathItem='Prop';
            dtlist{end+1}=localResult;
            sharedLists={dtlist};
        end
    end

    if h.isSameDTConfiguration(blkObj)
        portA=h.hShareDTSpecifiedPorts(blkObj,1,[]);
        portC=h.hShareDTSpecifiedPorts(blkObj,3,[]);
        currentSharedList={portA{1},portC{1}};
        sharedLists=h.hAppendToSharedLists(sharedLists,currentSharedList);
    end

    sharedSamePortSrc=hShareSrcAtSamePort(h,blkObj);
    sharedLists=h.hAppendToSharedLists(sharedLists,sharedSamePortSrc);
end

