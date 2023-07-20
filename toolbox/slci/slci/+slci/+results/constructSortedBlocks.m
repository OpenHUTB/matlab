

function[blockKeys,keyToHandle]=constructSortedBlocks(allBlks,...
    rootInports,virtualBlks,keyToHandle,datamgr,mfModel)
    assert(nargin==5||nargin==6);


    isResultsMF=(nargin==6);
    numBlks=numel(allBlks);
    blockKeys=cell(numBlks,1);

    if~isResultsMF
        datamgr.beginTransaction();
    end
    try
        if isResultsMF
            blockReader=datamgr;
        else
            blockReader=datamgr.getBlockReader();
        end
        for k=1:numBlks

            bHandle=allBlks(k);
            if isResultsMF
                bObject=slci_results_mf.BlockObject(mfModel);
                bObject.initializeBlockObject(bHandle);
            else
                bObject=slci.results.BlockObject(bHandle);
            end

            if find(rootInports==bHandle,1)
                bObject.setIsRootInport();
            elseif isSimOnly(bHandle)||...
                any(find(virtualBlks==bHandle,1))
                bObject.setIsVirtual();
            elseif strcmpi(get_param(bHandle,'BlockType'),'Ground')

                bObject.setIsVirtual();
            end


            if isResultsMF
                keyVal=bObject.key;
                blockReader.insertObject(bObject);
            else
                keyVal=bObject.getKey;
                blockReader.insertObject(keyVal,bObject);
            end
            blockKeys{k}=keyVal;
            keyToHandle(keyVal)=bHandle;
        end
    catch ex
        if~isResultsMF
            datamgr.rollbackTransaction();
        end
        throw(ex);
    end
    if~isResultsMF
        datamgr.commitTransaction();
    end
end

function simOnly=isSimOnly(blkH)



    blkType=get_param(blkH,'BlockType');
    if strcmpi(blkType,'DataTypeDuplicate')
        simOnly=true;
    elseif strcmpi(blkType,'S-Function')&&...
        strcmpi(get_param(blkH,'MaskType'),'Data Type Propagation')
        simOnly=true;
    else
        simOnly=false;
    end
end
