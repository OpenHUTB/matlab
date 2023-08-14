


function processedBlks=updateOrigBlock(synBlkHdl,...
    origBlk,...
    processedBlks,...
    blockReader)

    isResultsMF=isa(blockReader,'slci_results_mf.ReaderObject_MF');


    if isResultsMF

        synBlkKey=sprintf('%10.10f',synBlkHdl);

        assert(blockReader.hasObject(synBlkKey));

        synBlkObj=blockReader.getObject(synBlkKey);
        synBlkObj.origBlock=origBlk.key;
    else

        synBlkKey=slci.results.HiddenBlockObject.constructKey(synBlkHdl);

        assert(blockReader.hasObject(synBlkKey));

        synBlkObj=blockReader.getObject(synBlkKey);
        synBlkObj.setOrigBlock(origBlk);
    end





    if strcmpi(get_param(synBlkHdl,'BlockType'),'SubSystem')...
        &&~strcmpi(get_param(synBlkHdl,'Name'),'CoreSubsys')

        if slcifeature('BEPSupport')==1
            blkList=slci.internal.getCompBlockList(synBlkHdl);
        else
            blkList=slci.internal.getBlockList(synBlkHdl);
        end
        numBlks=numel(blkList);
        for k=1:numBlks
            hiddenBlkHdl=blkList(k);

            if isempty(find(processedBlks==hiddenBlkHdl,1))
                processedBlks(end+1)=hiddenBlkHdl;%#ok<AGROW>
                processedBlks=slci.results.updateOrigBlock(...
                hiddenBlkHdl,...
                origBlk,...
                processedBlks,...
                blockReader);
            end
        end
    end
    if~isResultsMF
        blockReader.replaceObject(synBlkKey,synBlkObj);
    end


end
