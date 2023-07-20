function result=restore(sourceKey,rangeIds,rangeLimits,destinationPosition)




    result='success';
    try
        if~rmiml.hasData(sourceKey)
            error('rmiml:duplicate:UnknownSource',['rmiml.restore() knows nothing about ',strrep(sourceKey,'\','\\')]);
        elseif rangeIds.size~=rangeLimits.size
            error('rmiml:duplicate:InconsistentSize','rmiml.restore() called with %d IDs and %d ranges',rangeIds.size,rangeLimits.size);
        else
            itIds=rangeIds.iterator;
            itRanges=rangeLimits.iterator;
            while itIds.hasNext
                id=itIds.next;
                range=itRanges.next;
                success=restoreItem(sourceKey,id,range,destinationPosition+1);
                if~success
                    error('rmiml:duplicate:FailedItem','rmiml.restore() failed to restore item %s:%s',sourceKey,id);
                end
            end
        end
    catch ex
        result=ex.message;
    end
end

function success=restoreItem(sourceKey,id,range,destPosition)
    try
        local_updateTextRange(sourceKey,id,[destPosition+range.x,destPosition+range.y]);
        com.mathworks.toolbox.simulink.slvnv.RmiDataLink.fireUpdateEvent(sourceKey,id);
        success=true;
    catch mex
        rmiut.warnNoBacktrace(mex.message);
        success=false;
    end
end

function local_updateTextRange(sourceKey,id,newRange)
    range=slreq.utils.getLinkedRanges(sourceKey,id);
    range.startPos=newRange(1);
    range.endPos=newRange(2);
end

