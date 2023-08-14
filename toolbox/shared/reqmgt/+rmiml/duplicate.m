function result=duplicate(sourceKey,rangeIds,rangeLimits,destinationKey,destinationPosition)




    result='success';
    try
        if~rmiml.hasData(sourceKey)
            error('rmiml:duplicate:UnknownSource',['rmiml.duplicate() knows nothing about ',strrep(sourceKey,'\','\\')]);
        elseif rangeIds.size~=rangeLimits.size
            error('rmiml:duplicate:InconsistentSize','rmiml.duplicate() called with %d IDs and %d ranges',rangeIds.size,rangeLimits.size);
        else
            itIds=rangeIds.iterator;
            itRanges=rangeLimits.iterator;
            while itIds.hasNext
                id=itIds.next;
                range=itRanges.next;
                newRange=[(destinationPosition+range.x),(destinationPosition+range.y)]+1;
                success=rmiml.duplicateLinks(sourceKey,id,destinationKey,newRange);
                if~success
                    error('rmiml:duplicate:FailedItem','rmiml.duplicate() failed to duplicate item %s:%s',sourceKey,id);
                end
            end
        end
    catch ex
        result=ex.message;
    end
end

