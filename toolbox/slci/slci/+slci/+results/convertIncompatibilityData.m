function convertIncompatibilityData(Config,compatCheckResults)

    dm=Config.getDataManager();
    incompReader=dm.getIncompatibilityReader();
    numIncompatibilities=numel(compatCheckResults.Incompatibilities);











    dm.beginTransaction();
    try
        for k=1:numIncompatibilities
            thisIncomp=compatCheckResults.Incompatibilities(k);





            cObject=slci.results.IncompatibilityObject(thisIncomp);
            objectsInvolved=thisIncomp.getObjectsInvolved();





            bKeys={};
            for p=1:numel(objectsInvolved)
                blkHandles=objectsInvolved{p};
                if isa(blkHandles,'double')
                    for blkidx=1:numel(blkHandles)
                        blkH=blkHandles(blkidx);
                        if strcmpi(get_param(blkH,'type'),'Block')
                            bKeys{end+1}=slci.results.BlockObject.constructKey(blkH);%#ok
                        end
                    end
                end



            end






            cObject.setObjectsInvolved(bKeys);

            incompReader.insertObject(cObject.getKey(),cObject);

        end
    catch ex
        dm.rollbackTransaction();
        throw(ex);
    end
    dm.commitTransaction();

end
