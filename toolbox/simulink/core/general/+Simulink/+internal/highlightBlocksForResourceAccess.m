function highlightBlocksForResourceAccess(actionSubsysH,ownerBlkH,stateName)




    if isempty(ownerBlkH)
        return;
    end

    actObj=get_param(actionSubsysH,'Object');
    subObj=actObj.up;


    sObj=Simulink.ResourceAccessorLinks(ownerBlkH,'state');

    modelObj=get_param(bdroot(ownerBlkH),'Object');


    set_param(ownerBlkH,'HiliteAncestors','find');


    for idx=1:numel(sObj.StateInfo)
        if strcmp(stateName,sObj.StateInfo(idx).Name)
            for idxRead=1:numel(sObj.StateInfo(idx).ReaderBlocks)
                reader=sObj.StateInfo(idx).ReaderBlocks(idxRead);
                blkObj=get_param(reader,'Object');
                if isBlockInsideSubsys(blkObj,subObj,modelObj)

                    set_param(reader,'HiliteAncestors','find');
                end
            end
            for idxWrite=1:numel(sObj.StateInfo(idx).WriterBlocks)
                writer=sObj.StateInfo(idx).WriterBlocks(idxRead);
                blkObj=get_param(writer,'Object');
                if isBlockInsideSubsys(blkObj,subObj,modelObj)

                    set_param(writer,'HiliteAncestors','find');
                end
            end
        end
    end
end

function ret=isBlockInsideSubsys(blkObj,subsysObj,modelObj)
    ret=false;
    parentObj=blkObj.up;
    while(parentObj~=modelObj)&&(parentObj~=subsysObj)
        parentObj=parentObj.up;
    end
    if parentObj==subsysObj
        ret=true;
    end
end

